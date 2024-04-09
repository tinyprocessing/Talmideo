import Foundation
import UIKit

protocol ExploreItemViewDelegate: AnyObject {
    func didTap(_ model: ExploreItemView.ExploreItemModel)
}

class ExploreItemView: UIView {
    private var model: ExploreItemModel

    public var delegate: ExploreItemViewDelegate?

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: model.image)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true

        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)

        let tintView = UIView(frame: view.bounds)
        tintView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tintView)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = model.title
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = model.subtitle
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private lazy var secondaryLabel: ExploreLabel = {
        let label = ExploreLabel()
        label.text = model.secondary
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        backgroundView.layer.cornerRadius = 8
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        label.addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16).isActive = true
        backgroundView.topAnchor.constraint(equalTo: label.topAnchor, constant: -16).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 16).isActive = true
        label.sendSubviewToBack(backgroundView)

        return label
    }()

    private lazy var playButton: ActionButton = {
        let button = ActionButton()
        button.setImage(Config.iconPlay, for: .normal)
        button.setImage(Config.iconPlay, for: .highlighted)
        button.setImage(Config.iconPlay, for: .selected)
        button.tintColor = .white
        button.backgroundColor = Config.buttonColor
        button.layer.cornerRadius = 30
        button.layer.shadowColor = Config.buttonColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.7
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()

    public struct ExploreItemModel {
        var type: ExploreCoordinator.ExploreIndex = .noun
        var image = ""
        var title = ""
        var subtitle = ""
        var secondary = ""
    }

    init(model: ExploreItemModel) {
        self.model = model
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(imageView)
        imageView.addSubview(titleLabel)
        imageView.addSubview(subtitleLabel)
        imageView.addSubview(playButton)
        imageView.addSubview(secondaryLabel)
        configure()
    }

    private func configure() {
        backgroundColor = Constants.backgroundColor
        layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 20),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),

            subtitleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 40),

            secondaryLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 0),
            secondaryLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20),
            secondaryLabel.heightAnchor.constraint(equalToConstant: 25),

            heightAnchor.constraint(equalToConstant: 160),

            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            playButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -20),
            playButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -20)
        ])
    }

    @objc private func playButtonTapped() {
        delegate?.didTap(model)
    }

    private enum Config {
        static let buttonColor = UIColor(hex: "FFC75A")
        static let title = ""
        static var iconPlay: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .default)
            return UIImage(systemName: "play.fill", withConfiguration: config) ?? UIImage()
        }
    }
}

private class ExploreLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
