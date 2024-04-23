
import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    private let arGuideView = ARGuideView()
    let arConfiguration = ARImageTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        arConfiguration.maximumNumberOfTrackedImages = 4
        UIApplication.shared.isIdleTimerDisabled = true
        arView.renderOptions = [.disableGroundingShadows]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    private func resetTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        arConfiguration.trackingImages = referenceImages
        arView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func configureLayout() {
        arGuideView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            arGuideView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            arGuideView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arGuideView.widthAnchor.constraint(equalToConstant: 300),
            arGuideView.heightAnchor.constraint(equalToConstant: 150),
        ])
        
        arGuideView.isHidden = true
    }
    
    //이미지 인식이 성공하였을 때의 로직을 담당하는 델리게이트 메서드
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            // 이미지 인식 성공시 ARImageAnchor 생성
            guard let imageAnchor = anchor as? ARImageAnchor else { return }
            
            // 인식 성공한 이미지의 이름을 기반으로 정보 가져오기
            let referenceImage = imageAnchor.referenceImage
            guard let imageIndex = markerImages.firstIndex(where: { $0.name == referenceImage.name }) else {
                return print("이미지 정보를 불러오지 못했습니다.")
            }
            
            let imageName = markerImages[imageIndex].name
            let imageCategory = markerImages[imageIndex].category.rawValue
            let imageDescription = markerImages[imageIndex].description
            guard let colorImage = UIImage(named: "Color" + "\(imageName)") else { return }
            
            arGuideView.updateImage(with: colorImage)
            arGuideView.updateInformationView(name: imageName, category: imageCategory, description: imageDescription)
            
            // extentions asImage() 메서드로 UIView를 UIImage로 변환 - Information View
            arGuideView.isHidden = false
            guard let arGuideViewImage = self.arGuideView.asImage().resized(toSize: CGSize(width: 200, height: 100)) else {
                return print("이미지 사이즈 조절에 실패했습니다.")
            }
            arGuideView.isHidden = true

            let arGuideTemp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            guard let imageData = arGuideViewImage.jpegData(compressionQuality: 1.0) else {
                fatalError("Failed to convert UIImage to Data")
            }
            try! imageData.write(to: arGuideTemp)
            guard let informationTexture = try? TextureResource.load(contentsOf: arGuideTemp) else {
                fatalError("Couldn't find image")
            }
            
            // Entity(3D오브젝트) 생성
            let detectPlaneMaterial = UnlitMaterial(color: .white.withAlphaComponent(0.5))

            let detectPlane = MeshResource.generatePlane(width: Float(referenceImage.physicalSize.width), height: Float(referenceImage.physicalSize.height))
            let detectPlaneEntity = ModelEntity(mesh: detectPlane, materials: [detectPlaneMaterial])
            
            var infomationPlaneMaterial = UnlitMaterial(color: .white)
            infomationPlaneMaterial.color =  SimpleMaterial.BaseColor(tint: .white.withAlphaComponent(1), texture: .init(informationTexture))
            let infomationPlane = MeshResource.generatePlane(width: Float(0.2), height: Float(0.1), cornerRadius: 0.005)
            let infomationPlaneEntity = ModelEntity(mesh: infomationPlane, materials: [infomationPlaneMaterial])
            
            // Entity(3D오브젝트)의 위치 설정
            let detectPlanePosition = SIMD3<Float>(0, 0, 0)
            detectPlaneEntity.position = detectPlanePosition
            detectPlaneEntity.transform.rotation = simd_quatf(angle:  -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
            
            let planeSize = SIMD2<Float>(Float(referenceImage.physicalSize.width), Float(referenceImage.physicalSize.height))
            let planeCenter = SIMD3<Float>(0, 0, 0)
            let planeCorner = SIMD3<Float>(0, (planeSize.x / 2 - 0.1), (planeSize.y / 2 + 0.05))
            let informationPlanePostion = planeCenter + planeCorner
            
            infomationPlaneEntity.position = informationPlanePostion
            infomationPlaneEntity.transform.rotation = simd_quatf(angle:  -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
            
            // 앵커 설정
            let anchorEntity = AnchorEntity(anchor: imageAnchor)
            
            
            // 앵커에 Entity 추가
            anchorEntity.addChild(detectPlaneEntity)
            anchorEntity.addChild(infomationPlaneEntity)
            
            // 씬에 앵커 추가
            arView.scene.addAnchor(anchorEntity)
        }
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
