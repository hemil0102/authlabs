
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
        }
        
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
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
