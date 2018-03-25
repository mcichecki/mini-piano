import Foundation
import AVFoundation

protocol SpeechSynthesizerDelegate: class {
    func changeLabel(i: Int)
}

class SpeechSynthesizer: NSObject {
    
    private let synthesizer = AVSpeechSynthesizer()
    private var i: Int = 0
    private var sentences: [String] = []
    weak var delegate: SpeechSynthesizerDelegate?
    
    init(_ sentences: [String]) {
        super.init()
        self.sentences = sentences
        synthesizer.delegate = self
    }
    
    func speak() {
        guard i < sentences.count else {
            return
        }
        
        let trimmedSentence = sentences[i].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        let utterance = AVSpeechUtterance(string: trimmedSentence)
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.2
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        self.sentences = []
    }
}

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        if let delegate = delegate {
            delegate.changeLabel(i: i)
        }
        i += 1
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speak()
    }
}
