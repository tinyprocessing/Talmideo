import Foundation
import UIKit

class CardTimerView: UIView {
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()

    private var timer: Timer?
    private var startTime: Date?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        startTimer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        startTimer()
    }

    private func setupViews() {
        addSubview(timerLabel)

        NSLayoutConstraint.activate([
            timerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            timerLabel.topAnchor.constraint(equalTo: topAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateTimer()
        }
    }

    private func updateTimer() {
        guard let startTime = startTime else { return }
        let currentDate = Date()
        let elapsedTime = Int(currentDate.timeIntervalSince(startTime))
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
