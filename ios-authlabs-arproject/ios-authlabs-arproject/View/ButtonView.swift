import UIKit

class ButtonView: UIView {

    private lazy var ButtonNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 0 // 여러 줄 표시 가능
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
        ButtonNameLabel.textColor = .white
    }
    
    private func setupViews() {
        ButtonNameLabel.text = "추가 검색"
        addSubview(ButtonNameLabel)
        NSLayoutConstraint.activate([
            ButtonNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            ButtonNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
