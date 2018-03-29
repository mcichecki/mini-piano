import Foundation
import SpriteKit
import AVFoundation

public class PianoKey: SKShapeNode {
    public var keyColor: UIColor! {
        return UIColor.white
    }
    
    public static var isSpeakerEnabled = false
    
    private var note: Note!
    private var sound: AVAudioPlayer!
    private var keyAlpha: CGFloat = 1.0
    private var keyPosition: CGPoint = CGPoint()
    private let speechSynthesizer = SpeechSynthesizer()
    
    public init(note: Note, position: CGPoint, sound: AVAudioPlayer) {
        super.init()
        
        let uiBezierPath = keyPath(position)
        self.keyPosition = position
        self.path = uiBezierPath
        self.fillColor = keyColor
        self.name = note.rawValue
        self.isUserInteractionEnabled = true
        self.note = note
        self.sound = sound
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func keyPath(_ position: CGPoint) -> CGPath {
        fatalError("Must be implemented by the subclass")
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if Piano.isHeartAndSoulPlaying || Piano.isJingleBellsPlaying {
            return
        }
        
        let location = touches.first!.location(in: self)
        if atPoint(location).name == self.name && location.y <= self.frame.maxY {
            handleTouch()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleEndOfTouch()
    }
    
    public func handleTouch() {
        playSound()
        showNote()
        if PianoKey.isSpeakerEnabled {
            speakNote()
        }
    }
    
    public func handleEndOfTouch() {
        fatalError("Must be implemented by the subclass")
    }
    
    func showNote() {
        let noteLabel = SKLabelNode(fontNamed: "SFCompactText-Regular")
        
        let moveUpAction = SKAction.moveBy(x: 0, y: 250, duration: 0.9)
        let increaseSizeAction = SKAction.scale(by: 2.5, duration: 0.8)
        let fadeAction = SKAction.fadeAlpha(to: 0, duration: 0.9)
        
        var width: CGFloat = 0.0
        if self is WhitePianoKey {
            width = WhitePianoKey.width
        } else {
            width = BlackPianoKey.width
        }
        noteLabel.position = CGPoint(x: self.keyPosition.x + width/2,
                                     y: self.keyPosition.y + WhitePianoKey.height * 0.7)
        noteLabel.text = note.rawValue
        noteLabel.fontSize = 24.0
        noteLabel.fontColor = keyColor
        noteLabel.zPosition = -1.0
        
        let actionGroup = SKAction.group([moveUpAction, increaseSizeAction, fadeAction])
        
        noteLabel.run(actionGroup) {
            noteLabel.removeFromParent()
        }
        
        self.addChild(noteLabel)
    }
    
    private func playSound() {
        sound.stop()
        sound.currentTime = TimeInterval(0.0)
        sound.play()
    }

    private func speakNote() {
        speechSynthesizer.stop()
        speechSynthesizer.speakNote(note.rawValue)
    }
}
