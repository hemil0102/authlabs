import UIKit
import RealityKit
import ARKit
import Combine

final class ImageTrackingViewController: UIViewController {
    
    //MARK: 뷰와 프로퍼티 생성
    @IBOutlet weak var arView: ARView!
    private let arConfiguration = ARImageTrackingConfiguration()
    
    private lazy var precheckView = PrecheckView()
    lazy var arGuideTextureView = ARGuideTextureView()
    lazy var searchButtonTextureView = SearchButtonTextureView()
    private let buttonStackView = UIStackView()
    
    lazy var buttonCapturedImage = UIImage()
    lazy var detectedColorImage = UIImage()
    
    private var messages = [RequestMessage]()
    var shouldCaptureImage: Bool = false
    var cancellable = Set<AnyCancellable>()
    
    //MARK: 버튼 생성
    private lazy var captureButton: UIButton = {
        return configureButton(title: "캡처", backgroundColor: UIColor.systemYellow.withAlphaComponent(0.8), action: #selector(captureButtonTapped))
    }()
    
    private lazy var imageSearchButton: UIButton = {
        return configureButton(title: "검색", backgroundColor: UIColor.systemPink.withAlphaComponent(0.8), action: #selector(imageSearchButtonTapped))
    }()
    
    //MARK: 생명 주기
    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureAR()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    //MARK: 버튼 수행 메서드
    @objc private func captureButtonTapped() {
        shouldCaptureImage = true
        resetTracking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.updatePrecheckView()
        }
    }
    
    @objc private func imageSearchButtonTapped() {
        let modalViewController = ModalViewController()
        generateGPTRequestMessage()
        modalViewController.referenceImage = detectedColorImage
        modalViewController.detectedImage = buttonCapturedImage
        modalViewController.messages = messages
        modalViewController.modalPresentationStyle = .overFullScreen
        self.present(modalViewController, animated: true, completion: nil)
    }
    
    //MARK: precheckView에 띄워줄 이미지를 업데이트
    private func updatePrecheckView() {
        self.precheckView.updateImage(with: self.buttonCapturedImage)
    }
    
    //MARK: AR resetTracking 이미지 트래킹 및 앵커 초기화
    func resetTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        arConfiguration.trackingImages = referenceImages
        arView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func restartARSession() {
        arView.session.pause()
        arView.scene.anchors.removeAll()
        arView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }

    //MARK: GPTRequestMessage 생성
    private func generateGPTRequestMessage() {
        guard let image64 = buttonCapturedImage.base64 else { return }
        messages.append(
            RequestMessage(
                role: .user,
                content: [
                    RequestContent(type: .text, text: "그림은 촬영된 이미지야 외곽에 조금 덜 잘려나간 배경은 무시해줘. 그림에 집중해서 정의와 설명을 특징등을 잘 잡아서 30~50자 내로 설명 해줘. Google Custom Search API에 같은 이미지가 검색될 수 있게 영어로 설명해주고 사람 이름, 모양, 패턴, 정의 등에 신경쓰고 심플한 특징을 알려줘! 글을 따옴표 안에 넣지마", image_url: nil),
                    RequestContent(type: .image_url, text: nil, image_url: ImageURL(url: "data:image/jpeg;base64,\(image64)"))
                ],
                toolCalls: nil)
        )
    }
    
    //MARK: 레이아웃 및 기타 설정
    private func cofigureAR() {
        arView.session.delegate = self
        arView.renderOptions = [.disableGroundingShadows]
        arConfiguration.maximumNumberOfTrackedImages = 1
        arConfiguration.worldAlignment = .gravity
        arConfiguration.isAutoFocusEnabled = true
        arConfiguration.frameSemantics = .personSegmentationWithDepth
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func configureButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backgroundColor
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func configureLayout() {
        arView.addSubview(buttonStackView)
        arView.addSubview(arGuideTextureView)
        arView.addSubview(searchButtonTextureView)
        arView.addSubview(precheckView)
        arView.addSubview(captureButton)
        arView.addSubview(imageSearchButton)
        
        arGuideTextureView.translatesAutoresizingMaskIntoConstraints = false
        searchButtonTextureView.translatesAutoresizingMaskIntoConstraints = false
        precheckView.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        imageSearchButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(captureButton)
        buttonStackView.addArrangedSubview(imageSearchButton)
        buttonStackView.distribution = .fillEqually
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.spacing = 0
        
        NSLayoutConstraint.activate([
            arGuideTextureView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            arGuideTextureView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            arGuideTextureView.widthAnchor.constraint(equalToConstant: 300),
            arGuideTextureView.heightAnchor.constraint(equalToConstant: 150),
            searchButtonTextureView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            searchButtonTextureView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchButtonTextureView.widthAnchor.constraint(equalToConstant: 130),
            searchButtonTextureView.heightAnchor.constraint(equalToConstant: 40),
            precheckView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),
            precheckView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            precheckView.widthAnchor.constraint(equalToConstant: 400),
            precheckView.heightAnchor.constraint(equalToConstant: 120),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25)
        ])
        
        arGuideTextureView.isHidden = true
        searchButtonTextureView.isHidden = true
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}


