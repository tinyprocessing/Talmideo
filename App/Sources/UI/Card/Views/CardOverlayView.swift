import AVFoundation
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

    private lazy var soundButton: ActionButton = {
        let button = ActionButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(Config.soundButton, for: .normal)
        button.setImage(Config.soundButton, for: .selected)
        button.layer.shadowColor = Config.buttonSoundColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.7
        button.backgroundColor = Config.buttonSoundColor
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black
        button.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
        return button
    }()

    private var wordDataView: WordDataView?

    init(_ model: WordModel) {
        self.model = model
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func initialize() {
        backgroundColor = .clear
        addSubview(backgroundView)
        backgroundView.anchorToSuperview()
        backgroundView.backgroundColor = UIColor(hex: "f2f2f2")
        backgroundView.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            headerView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
            headerView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10)
        ])
        update()
    }

    private func update() {
        if model.partOfSpeech == "V" {
            if let present = model.forms?.present {
                let view = createWordDataView()
                view.update(.present(value: present))
            }
        }
        if model.partOfSpeech == "N" {
            if let main = model.forms?.main {
                let view = createWordDataView()
                view.update(.noun(value: main, gender: model.gender ?? "M"))
            }
        }
        if model.partOfSpeech == "A" {
            if let adjective = model.forms?.main {
                let view = createWordDataView()
                view.update(.adjective(value: adjective))
            }
        }

        backgroundView.addSubview(soundButton)
        backgroundView.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            soundButton.widthAnchor.constraint(equalToConstant: 60),
            soundButton.heightAnchor.constraint(equalToConstant: 60),
            soundButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor)
        ])

        if let wordDataView = wordDataView {
            NSLayoutConstraint.activate([
                soundButton.topAnchor.constraint(equalTo: wordDataView.bottomAnchor, constant: 20)
            ])
        } else {
            NSLayoutConstraint.activate([
                soundButton.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20)
            ])
        }
    }

    private func createWordDataView() -> WordDataView {
        let view = WordDataView()
        backgroundView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, constant: -30).isActive = true
        view.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20).isActive = true
        view.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10).isActive = true
        view.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10).isActive = true
        view.widthAnchor.constraint(equalTo: headerView.widthAnchor).isActive = true
        wordDataView = view
        return view
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    @objc private func soundButtonTapped() {
        AVSpeechSynthesizer.shared.speak(model.initialForm?.transcription ?? "", language: "ru")
    }

    private enum Config {
        static let backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.05)
        static let buttonSoundColor = UIColor.secondaryLabel.withAlphaComponent(0.05)
        static var soundButton: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .default)
            return UIImage(systemName: "speaker.wave.2", withConfiguration: config) ?? UIImage()
        }
    }
}
