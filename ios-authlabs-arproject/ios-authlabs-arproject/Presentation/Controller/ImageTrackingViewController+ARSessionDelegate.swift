
import Foundation
import ARKit
import RealityKit
import CoreImage
import CoreImage.CIFilterBuiltins

//MARK: ARSessionDelegate
extension ImageTrackingViewController: ARSessionDelegate {
    
    //MARK: sessin didAdd를 통해 Anchor 변화를 감지한다.
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let imageAnchor = anchor as? ARImageAnchor else { return }
            handleImageAnchor(imageAnchor)
        }
    }

    //MARK: 생성된 ImageAnchor를 기준으로 3D객체와 위치를 지정하고 비즈니스 로직을 수행한다.
    private func handleImageAnchor(_ imageAnchor: ARImageAnchor) {
    
        //MARK: Image 앵커 정보 추출
        let referenceImage = imageAnchor.referenceImage
        let referenceImageWidth = Float(referenceImage.physicalSize.width)
        let referenceImageHeight = Float(referenceImage.physicalSize.height)
        
        //MARK: arGuidTextureView 업데이트 및 텍스쳐 형성
        arGuideTextureViewUpdate(with: referenceImage)
        let informationTexture = fetchTexture(from: arGuideTextureView, width: 200, height: 100)
        let buttonTexture = fetchTexture(from: searchButtonTextureView, width: 130, height: 40)
        
        //MARK: Entity(3D오브젝트) 생성과 위치 지정
        let detectPlaneEntity = self.generatePlaneEntity(materialColor: .red, opacity: 0, texture: nil, width: referenceImageWidth, height: referenceImageHeight, cornerRaidus: 0)
        let infomationPlaneEntity = self.generatePlaneEntity(materialColor: .white, opacity: 1, texture: informationTexture, width: Float(0.2), height: Float(0.1), cornerRaidus: 0.005)
        let buttonPlaneEntity = self.generatePlaneEntity(materialColor: .white, opacity: 1, texture: buttonTexture, width: Float(0.13), height: Float(0.04), cornerRaidus: 0.1)
        
        self.setEntityPosition(with: detectPlaneEntity, to: SIMD3<Float>(0, 0, 0))
        self.setEntityPosition(with: infomationPlaneEntity, to: SIMD3<Float>(0, 0.05, referenceImageHeight / 1.3))
        self.setEntityPosition(with: buttonPlaneEntity, to: SIMD3<Float>(0, 0.05, referenceImageHeight / 1.3) + SIMD3<Float>(0, 0, 0.075))
        
        //MARK: 앵커 설정 및 추가
        let anchorEntity = AnchorEntity(anchor: imageAnchor)

        anchorEntity.addChild(detectPlaneEntity)
        anchorEntity.addChild(infomationPlaneEntity)
        anchorEntity.addChild(buttonPlaneEntity)
        
        self.arView.scene.addAnchor(anchorEntity)
        
        //MARK: 인식한 영역 이미지를 가져오기
        if shouldCaptureImage {
            snapCroppedImage(arView: arView, imageAnchor: imageAnchor, referenceImageWidth: referenceImageWidth, referenceImageHeight: referenceImageHeight)
        }
    }
    
    //MARK: arGuidTextureView 업데이트
    private func arGuideTextureViewUpdate(with referenceImage: ARReferenceImage) {
        guard let detectedImage = getImageInformation(from: referenceImage) else { return }
        detectedColorImage = detectedImage.colorImage
        arGuideTextureView.updateImage(with: detectedColorImage)
        arGuideTextureView.updateInformationView(name: detectedImage.reference, category: detectedImage.category.rawValue, description: detectedImage.description)
    }
    
    //MARK: 인식한 이미지의 정보를 불러온다.
    private func getImageInformation(from referenceImage: ARReferenceImage) -> CapturedImage? {
        guard let imageIndex = markerImages.firstIndex(where: { $0.name == referenceImage.name }) else {
            print("이미지 정보를 불러오지 못했습니다.")
            return nil
        }
        
        let imageName = markerImages[imageIndex].name
        let imageCategory = markerImages[imageIndex].category
        let imageDescription = markerImages[imageIndex].description
        guard let colorImage = UIImage(named: "Color" + imageName) else { return nil }
        return CapturedImage(reference: imageName, category: imageCategory, description: imageDescription, colorImage: colorImage)
    }
    
    //MARK: 텍스처 불러오는 메서드
    private func fetchTexture(from tuxtureView: UIView, width: Double, height: Double) -> TextureResource? {
        let result = generateTexture(from: tuxtureView, width: width, height: height)

        switch result {
        case .success(let texture):
            return texture
        case .failure(let error):
            switch error {
            case .imageCreationFailed:
                print("Failed to create image.")
            case .imageDataCreationFailed:
                print("Failed to create image data.")
            case .textureLoadingFailed:
                print("Failed to load texture.")
            case .otherError(let underlyingError):
                print("An unexpected error occurred: \(underlyingError)")
            }
            return nil
        }
    }
    
    //MARK:  뷰를 이미지로 변환하고 텍스처를 생성한다.
    private func generateTexture(from textureView: UIView, width: Double, height: Double) -> Result<TextureResource, TextureGenerationError> {
        textureView.isHidden = false
        guard let textureViewImage = textureView.asImage().resized(toSize: CGSize(width: width, height: height)) else {
            return .failure(.imageDataCreationFailed)
        }
        textureView.isHidden = true
        
        do {
            let textureTemp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            guard let imageData = textureViewImage.jpegData(compressionQuality: 1.0) else {
                return .failure(.imageDataCreationFailed)
            }
            try imageData.write(to: textureTemp)
            guard let texture = try? TextureResource.load(contentsOf: textureTemp) else {
                  throw TextureGenerationError.textureLoadingFailed
            }
            return .success(texture)
            
        } catch {
            print("Error generating texture: \(error)")
            return .failure(.otherError(error))
        }
    }
    
    //MARK: 평면 Entity를 생성한다.
    private func generatePlaneEntity(materialColor: UIColor, opacity: CGFloat, texture: TextureResource?, width: Float, height: Float, cornerRaidus: Float) -> ModelEntity {
        var PlaneMaterial = UnlitMaterial(color: materialColor.withAlphaComponent(opacity))
        if let texture {
            PlaneMaterial.color =  SimpleMaterial.BaseColor(tint: materialColor, texture: .init(texture))
        }
        let Plane = MeshResource.generatePlane(width: width, height: height, cornerRadius: cornerRaidus)
        let PlaneEntity = ModelEntity(mesh: Plane, materials: [PlaneMaterial])
        
        return PlaneEntity
    }
    
    //MARK: Entity의 위치를 지정한다.
    private func setEntityPosition(with entity: ModelEntity, to postion: SIMD3<Float>) {
        entity.position = postion
        entity.transform.rotation = simd_quatf(angle:  -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
    }
 
    //MARK: 인식한 이미지의 모서리를 기준으로 인식한 영역의 이미지만 잘라온다.
    private func snapCroppedImage(arView: ARView, imageAnchor: ARImageAnchor, referenceImageWidth: Float, referenceImageHeight: Float) {
        let x = imageAnchor.transform.columns.3.x
        let y = imageAnchor.transform.columns.3.y
        let z = imageAnchor.transform.columns.3.z
        
        let imageAnchorPosition = SIMD3<Float>(x, y, z)
        
        guard let topLeft = arView.project(imageAnchorPosition + SIMD3<Float>(-referenceImageWidth/2, referenceImageHeight/2, 0)),
              let bottomLeft = arView.project(imageAnchorPosition + SIMD3<Float>(-referenceImageWidth/2, -referenceImageHeight/2, 0)),
              let topRight = arView.project(imageAnchorPosition + SIMD3<Float>(referenceImageWidth/2, referenceImageHeight/2, 0)),
              let bottomRight = arView.project(imageAnchorPosition + SIMD3<Float>(referenceImageWidth/2, -referenceImageHeight/2, 0)) else { return }
        
        let scale: CGFloat = 3
        let screenpointTopLeft = CGPoint(x: CGFloat(topLeft.x * scale), y: CGFloat(topLeft.y * scale))
        let screenpointBottomLeft = CGPoint(x: CGFloat(bottomLeft.x * scale), y: CGFloat(bottomLeft.y * scale))
        let screenpointTopRight = CGPoint(x: CGFloat(topRight.x * scale), y: CGFloat(topRight.y * scale))
        let screenpointBottomRight = CGPoint(x: CGFloat(bottomRight.x * scale), y: CGFloat(bottomRight.y * scale))
        
        arView.snapshot(saveToHDR: false) { image in
            guard let capturedImage = image, let ciImage = CIImage(image: capturedImage) else { return }
            
            guard let croppedImage = self.cropImageForPoints(image: ciImage, topLeft: screenpointTopLeft, topRight: screenpointTopRight, bottomLeft: screenpointBottomLeft, bottomRight: screenpointBottomRight) else { return }
            
            self.buttonCapturedImage = UIImage(ciImage: croppedImage)
            self.shouldCaptureImage = false
        }
    }

    //MARK: 인식한 모서리를 기준으로 CIFilter 이미지 왜곡 보정을 수행한다.
    private func cropImageForPoints(image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage? {
        let perspectiveTransformFilter = CIFilter.perspectiveCorrection()
        perspectiveTransformFilter.inputImage = image
        perspectiveTransformFilter.topLeft = CGPoint(x: topLeft.x - 10, y: image.extent.size.height - topLeft.y + 40)
        perspectiveTransformFilter.topRight = CGPoint(x: topRight.x - 35, y: image.extent.size.height - topRight.y + 40)
        perspectiveTransformFilter.bottomLeft = CGPoint(x: bottomLeft.x - 10, y: image.extent.size.height - bottomLeft.y + 30)
        perspectiveTransformFilter.bottomRight = CGPoint(x: bottomRight.x - 35, y: image.extent.size.height - bottomRight.y + 30)
    
        return perspectiveTransformFilter.outputImage!
    }
}

