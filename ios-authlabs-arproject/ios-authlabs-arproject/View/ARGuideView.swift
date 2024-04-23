
import UIKit

class ARGuideView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var imageNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureAppearance()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureAppearance()
        setupViews()
    }
    
    private func configureAppearance() {
        self.backgroundColor = .black
        imageNameLabel.textColor = .white
        imageCategoryLabel.textColor = .white
        imageDescriptionLabel.textColor = .white
    }
    
    private func setupViews() {
        addSubview(imageView)
        
        verticalStackView.addArrangedSubview(imageNameLabel)
        verticalStackView.addArrangedSubview(imageCategoryLabel)
        verticalStackView.addArrangedSubview(imageDescriptionLabel)
        horizontalStackView.addArrangedSubview(imageView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        
        addSubview(horizontalStackView)
        
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            imageNameLabel.widthAnchor.constraint(equalToConstant: 150),
            imageCategoryLabel.widthAnchor.constraint(equalToConstant: 150),
            imageDescriptionLabel.widthAnchor.constraint(equalToConstant: 150),
            
            imageView.topAnchor.constraint(equalTo: topAnchor),
            
            horizontalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            horizontalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2),
            horizontalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            horizontalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func updateImage(with referenceImage: UIImage) {
        imageView.image = referenceImage
        let aspectRatio = referenceImage.size.width / referenceImage.size.height
        let imageViewWidth = min(bounds.width, 250 * aspectRatio)
        let imageViewHeight = imageViewWidth / aspectRatio
        imageView.heightAnchor.constraint(equalToConstant: min(imageViewHeight, 250)).isActive = true
    }
    
    func updateInformationView(name: String, category: String, description: String) {
        imageNameLabel.text = name
        imageCategoryLabel.text = category
        imageDescriptionLabel.text = description
    }
}
