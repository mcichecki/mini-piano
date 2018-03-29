import Foundation
import AVFoundation

protocol SpeechSynthesizerDelegate: class {
    func changeLabel(i: Int)
}

class SpeechSynthesizer: NSObject {
    
    weak var delegate: SpeechSynthesizerDelegate?
    
    private let synthesizer = AVSpeechSynthesizer()
    private var i: Int = 0
    private var sentences: [String] = []
    private let notes = ["c","d","e","f","g","a","b"]
    
    init(_ sentences: [String]? = nil) {
        super.init()
        self.sentences = sentences ?? []
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
    
    func speakNote(_ note: String) {
        let noteUtterance = AVSpeechUtterance(string: String(note.first!).lowercased())
        noteUtterance.rate = 0.6
        noteUtterance.pitchMultiplier = mapNoteToPitch(note)
        synthesizer.speak(noteUtterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        self.sentences = []
    }
    
    private func mapNoteToPitch(_ note: String) -> Float {
        let noteToProcess = note.lowercased()
        let level = Float(noteToProcess.trimmingCharacters(in: CharacterSet.decimalDigits.inverted))
        let letter =  Float(notes.index(of: String(noteToProcess.first!))! + (level == 1 ? 0 : notes.count))
        let pitch = 1.5 * ((letter))/(13) + 0.5
        return pitch
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
