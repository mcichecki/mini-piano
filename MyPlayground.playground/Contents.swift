//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import SpriteKit
import AVFoundation

public enum Note: String {
    case C1, D1b, D1, E1, E1b, F1, G1, G1b, A1, A1b, H1, H1b,
    C2, D2b, D2, E2, E2b, F2, G2, G2b, A2, A2b, H2, H2b
}

public class PianoScene: SKScene {
    
    private let whiteNotes: [Note] = [.C1, .D1, .E1, .F1, .G1, .A1, .H1,
                                      .C2, .D2, .E2, .F2, .G2, .A2, .H2]
    
    private let blackNotes: [Note] = [.D1b, .E1b, .G1b, .A1b, .H1b,
                                      .D2b, .E2b, .G2b, .A2b, .H2b]
    
    private var noteSounds: [String: AVAudioPlayer] = [:]
    
    // UI
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor(red: 59/255.0, green: 60/255.0, blue: 61/255.0, alpha: 1.0)
        mapSounds()
        setupKeys()
    }
    
    private func setupKeys() {
        let startingPoint: CGFloat = self.view!.frame.width/2 - 7 * WhitePianoKey.width
        var endingPoint: CGFloat!
        var topPoint: CGFloat!
        var i = 0
        
        for (index, whiteNote) in whiteNotes.enumerated() {
            let position = CGPoint(x: startingPoint + CGFloat(index) * (WhitePianoKey.width + 1.0),
                                   y: 100)
            let whitePianoKey = WhitePianoKey(note: whiteNote,
                                              position: position,
                                              sound: noteSounds[whiteNote.rawValue]!)
            whitePianoKey.zPosition = 0.0
            topPoint = whitePianoKey.frame.maxY
            
            if index == whiteNotes.count - 1 {
                endingPoint = whitePianoKey.frame.maxX
            }
            
            if index != 2 && index != 6 && index != 9 && index != 13 {
                let blackPianoKey = BlackPianoKey(note: blackNotes[i],
                                                  position: CGPoint.init(x: whitePianoKey.frame.maxX - BlackPianoKey.width/2, y: topPoint - BlackPianoKey.height - 5.0),
                                                  sound: noteSounds[blackNotes[i].rawValue]!)
                blackPianoKey.zPosition = 1.0
                self.addChild(blackPianoKey)
                i += 1
            }
            
            self.addChild(whitePianoKey)
        }
        setupPiano(CGRect(x: startingPoint - 1,
                          y: topPoint - 20,
                          width: endingPoint - startingPoint + 1,
                          height: 20))
    }
    
    private func setupPiano(_ rect: CGRect) {
        let piano = SKShapeNode(rect: rect)
        piano.fillColor = UIColor.piano
        piano.strokeColor = UIColor.piano
        piano.zPosition = 2.0
        self.addChild(piano)
    }
    
    private func mapSounds() {
        for whiteNote in whiteNotes {
            noteSounds[whiteNote.rawValue] = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: whiteNote.rawValue,withExtension: "mp3")!)
        }
        
        for blackNote in blackNotes {
            noteSounds[blackNote.rawValue] = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: blackNote.rawValue, withExtension: "mp3")!)
        }
        
        for noteSound in noteSounds.values {
            noteSound.volume = 0.4
            noteSound.prepareToPlay()
        }
    }
}

public class PianoKey: SKShapeNode {
    public var keyColor: UIColor! {
        return UIColor.white
    }
    
    private var note: Note!
    private var sound: AVAudioPlayer!
    private let caShapeLayer = CAShapeLayer()
    private var keyAlpha: CGFloat = 1.0
    
    public init(note: Note, position: CGPoint, sound: AVAudioPlayer) {
        super.init()
        
        let uiBezierPath = keyPath(position)
        self.path = uiBezierPath
        self.fillColor = keyColor
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
        playSound()
    }
    
    private func playSound() {
        sound.stop()
        sound.currentTime = TimeInterval(0.0)
        sound.play()
    }
}

public class WhitePianoKey: PianoKey {
    public static let height: CGFloat = 140.0
    public static let width: CGFloat = 32.0
    
    public override func keyPath(_ position: CGPoint) -> CGPath {
        let keyRect = CGRect(origin: position, size: CGSize(width: WhitePianoKey.width, height: WhitePianoKey.height))
        return UIBezierPath(roundedRect: keyRect, cornerRadius: 5.0).cgPath
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.fillColor = UIColor.whiteKeyPressed
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.fillColor = UIColor.white
    }
}

public class BlackPianoKey: PianoKey {
    public static let height: CGFloat = 80.0
    public static let width: CGFloat = 20.0
    
    public override var keyColor: UIColor! {
        return UIColor.black
    }
    
    public override func keyPath(_ position: CGPoint) -> CGPath {
        let keyRect = CGRect(origin: position,
                             size: CGSize(width: BlackPianoKey.width, height: BlackPianoKey.height))
        
        return UIBezierPath(roundedRect: keyRect,
                            cornerRadius: 5.0).cgPath
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.fillColor = UIColor.blackKeyPressed
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.fillColor = UIColor.blackKey
    }
}

extension UIColor {
    static var piano = UIColor(red: 11/255.0, green: 24/255.0, blue: 41/255.0, alpha: 1.0)
    static var whiteKeyPressed = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0)
    static var blackKey = UIColor(red: 3/255.0, green: 3/255.0, blue: 3/255.0, alpha: 1.0)
    static var blackKeyPressed = UIColor(red: 43/255.0, green: 43/255.0, blue: 43/255.0, alpha: 1.0)
}

let pianoScene = PianoScene(size: CGSize(width: 600.0, height: 350.0))
let view = SKView(frame: CGRect(x: 0, y: 100, width: 600.0, height: 350.0))

view.presentScene(pianoScene)
PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true
