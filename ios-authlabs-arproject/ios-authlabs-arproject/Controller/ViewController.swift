
import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
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
            guard let colorImage = UIImage(named: "Color" + "\(imageName)") else { return  }
        }
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
