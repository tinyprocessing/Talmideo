import Foundation
import UIKit

class OnboardingView: UIViewController {
    struct DMOnboardingModel {
        let title: String
        let subtitle: String
        let image: UIImage

        init(title: String, subtitle: String, image: UIImage) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
        }
    }

    private var model: DMOnboardingModel

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = model.title
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.customFont(.robotoSlabMedium, size: 24)
        return label
    }()

    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = model.image
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 170
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = model.subtitle
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.customFont(.robotoSlabRegular, size: 20)
        return label
    }()

    init(title: String, subtitle: String, image: UIImage) {
        model = .init(title: title, subtitle: subtitle, image: image)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Config.offest),
            imageView.widthAnchor.constraint(equalToConstant: Config.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Config.imageSize),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Config.spacing),
            titleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Config.multiplier),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Config.spacing),
            subtitleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            subtitleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Config.multiplier)
        ])
    }

    private enum Config {
        static let imageSize: CGFloat = 340
        static let spacing: CGFloat = 30
        static let multiplier: CGFloat = 0.9
        static let offest: CGFloat = -100
    }
}
