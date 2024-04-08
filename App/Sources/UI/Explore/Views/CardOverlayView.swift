import UIKit

class CardContentView: UIView {
    private let model: WordModel
    private let backgroundView: UIView = {
        let background = UIView()
        background.clipsToBounds = true
        background.layer.cornerRadius = 25
        return background
    }()

    private lazy var headerView: WordHeaderView = {
        let view = WordHeaderView()
        view.update(model)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.01).cgColor,
                           UIColor.black.withAlphaComponent(0.8).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        return gradient
    }()

    init(_ model: WordModel) {
        self.model = model
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func initialize() {
        backgroundColor = Constants.backgroundColor
        addSubview(backgroundView)
        backgroundView.anchorToSuperview()
        backgroundView.backgroundColor = UIColor(hex: "D9EDBF").withAlphaComponent(0.2)
        backgroundView.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            headerView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20)
        ])
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let heightFactor: CGFloat = 0.35
        gradientLayer.frame = CGRect(x: 0,
                                     y: (1 - heightFactor) * bounds.height,
                                     width: bounds.width,
                                     height: heightFactor * bounds.height)
    }
}
