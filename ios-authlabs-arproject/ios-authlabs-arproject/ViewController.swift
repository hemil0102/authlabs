
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
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // set initial project
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
