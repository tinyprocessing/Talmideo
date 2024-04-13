import AVFoundation
import Foundation

class SoundManager {
    static let shared = SoundManager()

    enum Sound: String {
        case cardSwipe
        case cardSwipeCalm
    }

    private var player: AVAudioPlayer?

    func playSoundEffect(_ sound: Sound) {
        DispatchQueue.global().async {
            guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
                return
            }

            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                self.player = try AVAudioPlayer(contentsOf: url)
                self.player?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
}

extension AVSpeechSynthesizer {
    private struct Storage {
        static let shared = AVSpeechSynthesizer()
    }

    static let shared: AVSpeechSynthesizer = {
        let synthesizer = Storage.shared
        return synthesizer
    }()

    func speak(_ string: String, language: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language)

        if isSpeaking {
            stopSpeaking(at: .immediate)
        }
        speak(utterance)
    }
}
