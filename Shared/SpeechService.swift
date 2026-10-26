import Foundation
import AVFoundation

/// Pronuncia texto en alemán usando la síntesis de voz del sistema (voz `de-DE`).
///
/// Es un singleton observable para que la UI pueda reflejar cuándo está hablando.
/// Configura la sesión de audio como `.playback`, de modo que la pronunciación
/// se escuche incluso con el interruptor de silencio activado.
final class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    /// Indica si en este momento se está pronunciando algo (para animar el botón).
    @Published private(set) var isSpeaking = false

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Pronuncia el texto dado en alemán. Si ya estaba hablando, corta lo anterior.
    /// - Parameters:
    ///   - text: Texto a pronunciar (p. ej. "der Hund" o una frase de ejemplo).
    ///   - rate: Velocidad de habla (0…1). Un poco más lento que el default ayuda a aprender.
    func speakGerman(_ text: String, rate: Float = 0.45) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        activateAudioSession()

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }

    /// Detiene cualquier pronunciación en curso.
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    private func activateAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        #endif
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = true }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
