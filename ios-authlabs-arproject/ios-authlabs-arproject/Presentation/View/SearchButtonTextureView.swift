import UIKit

class SearchButtonTextureView: UIView {
    
    private lazy var buttonNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
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
        self.backgroundColor = .systemPink
        buttonNameLabel.textColor = .white
    }
    
    private func setupViews() {
        buttonNameLabel.text = "추가 검색"
        addSubview(buttonNameLabel)
        NSLayoutConstraint.activate([
            buttonNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
