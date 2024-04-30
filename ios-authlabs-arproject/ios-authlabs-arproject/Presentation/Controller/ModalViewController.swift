import UIKit
import Combine

//MARK: 이미지 검색 모달 화면 뷰컨트롤러
class ModalViewController: UIViewController {
    
    //MARK: 프로퍼티 생성
    private let mapper = Mapper(dataDecoder: DataDecoder(networkManager: NetworkManager()))
    private let imageAnalyzer = ImageSimilarityAnalyzer()
    private var imageSimilarities = [Float]()
    private var cancellable = Set<AnyCancellable>()
    var messages = [RequestMessage]()
    var referenceImage = UIImage()
    var detectedImage = UIImage()
    private var searchedImage = UIImage()
    private var searchedImages = [UIImage]()
    private var imageSimilarityLabels = [UILabel]()
    private var imageURL = [URL]()
    
    //MARK: 레이블과 이미지뷰 생성
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var referenceLabel: UILabel = {
        let label = UILabel()
        label.text = "원본 이미지"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var detectedLabel: UILabel = {
        let label = UILabel()
        label.text = "인식 이미지"
        label.textAlignment = .center
        return label
    }()
    
    //MARK: 버튼 생성
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.systemPink
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return closeButton
    }()
    
    private lazy var searchedImagesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: searchedImageViews)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var imageSimilarityLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: imageSimilarityLabels)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    //MARK: 뷰 생성
    private lazy var referenceimageView: UIImageView = {
        return createImageView(with: referenceImage)
    }()
    
    private lazy var dectectedimageView: UIImageView = {
        return createImageView(with: detectedImage)
    }()
    
    private lazy var searchedImageViews: [UIImageView] = {
        var imageViews: [UIImageView] = []
        for _ in 0..<3 {
            let imageView = UIImageView(image: searchedImage)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageViews.append(imageView)
        }
        return imageViews
    }()
    
    private lazy var leftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [referenceLabel, referenceimageView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detectedLabel, dectectedimageView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var topimageViewStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //MARK: 생명 주기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLayout()
        fetchGPTData()
    }
    
    //MARK: 인식한 이미지를 통해서 GPT 설명을 가져온다.
    func fetchGPTData() {
        return mapper.mapChatGPTContent(with: messages)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] message in
                DispatchQueue.main.async {
                    self?.descriptionLabel.text = message[0].content
                    self?.fetchImages(with: message[0].content)
                }
            })
            .store(in: &cancellable)
    }
    
    //MARK: GPT설명을 근거해 유사한 이미지를 가져온다.
    func fetchImages(with searchWord: String) {
        print("searchWord \(searchWord)")
        mapper.mapGoogleImageData(with: searchWord)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] result in
                self?.imageURL = result
                self?.updateSearchedImages(with: self?.imageURL ?? [URL(fileURLWithPath: "Error")])
            }
            .store(in: &cancellable)
    }
    
    //MARK: 유사하 이미지 3장을 뷰에 업데이트 하고 유사도를 측정한다.
    func updateSearchedImages(with images: [URL]) {
        let group = DispatchGroup()
        
        for (index, url) in images.enumerated() {
            let urlString = url.absoluteString
            group.enter()
            loadImage(from: urlString) { image in
                defer { group.leave() }
                guard let loadedImage = image else { return }
                DispatchQueue.main.async {
                    if index < self.searchedImageViews.count {
                        self.searchedImageViews[index].image = loadedImage
                        self.searchedImages.append(loadedImage)
                        
                        //MARK: 이미지를 받아올 때마다 유사도 측정 및 레이블 생성하여 추가
                        let similarity = self.imageAnalyzer.measureSimilarityBetween(image1: self.referenceImage, image2: loadedImage)
                        let similarityLabel = self.createSimilarityLabel(with: similarity)
                        self.imageSimilarityLabels.append(similarityLabel)
                        self.imageSimilarityLabelStackView.addArrangedSubview(similarityLabel)
                    }
                }
            }
        }
    }
    
    //MARK: 레이아웃을 설정한다.
    private func configureLayout() {
        view.addSubview(descriptionLabel)
        view.addSubview(closeButton)
        
        let stackView = UIStackView(arrangedSubviews: [topimageViewStackView, searchedImagesStackView, imageSimilarityLabelStackView , descriptionLabel, closeButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topimageViewStackView.heightAnchor.constraint(equalToConstant: 150),
            searchedImagesStackView.heightAnchor.constraint(equalToConstant: 100),
            imageSimilarityLabelStackView.heightAnchor.constraint(equalToConstant: 40),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 180),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -100),
        ])
    }
    
    //MARK: URL로된 주소를 이미지로 변환한다.
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
  
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(image)
            }
        }.resume()
    }
    
    //MARK: 이미지뷰 생성
    private func createImageView(with image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    //MARK: 유사도를 표시할 레이블을 생성하는 함수
    private func createSimilarityLabel(with similarity: Float) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .systemYellow
        label.text = String(format: "%.2f", similarity)
        return label
    }
    
    //MARK: 모달을 닫아준다.
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}


