import Foundation
import SpriteKit
import AVFoundation

public protocol PianoDelegate {
    func setHeartAndSoul(value: Bool)
    func setJingleBells(value: Bool)
}

public enum Note: String {
    case
    C3, D3b, D3, E3, E3b, F3, G3, G3b, A3, A3b, B3, B3b,
    C4, D4b, D4, E4, E4b, F4, G4, G4b, A4, A4b, B4, B4b,
    pause
}

public class Piano: SKShapeNode {
    
    public var delegate: PianoDelegate?
    public var snowEmitter: SKEmitterNode?
    public static var isHeartAndSoulPlaying: Bool = false
    public static var isJingleBellsPlaying: Bool = false
    public enum Song: Int {
        case heartAndSoul, jingleBells
    }
    
    private var timer: Timer?
    private var noteSounds: [String: AVAudioPlayer] = [:]
    private let whiteNotes: [Note] = [.C3, .D3, .E3, .F3, .G3, .A3, .B3,
                                      .C4, .D4, .E4, .F4, .G4, .A4, .B4]
    private let blackNotes: [Note] = [.D3b, .E3b, .G3b, .A3b, .B3b,
                                      .D4b, .E4b, .G4b, .A4b, .B4b]
    
    public init(timer: Timer) {
        self.timer = timer
        super.init()
        mapSounds()
        setupKeys()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func playSong(with notes: [Note], speed: TimeInterval, chosenSong: Song) {
        guard !(Piano.isHeartAndSoulPlaying || Piano.isJingleBellsPlaying) else {
            timer?.invalidate()
            timer = nil
            if Piano.isHeartAndSoulPlaying {
                delegate?.setHeartAndSoul(value: false)
            }
            
            if Piano.isJingleBellsPlaying {
                delegate?.setJingleBells(value: false)
            }
            return
        }
        
        switch chosenSong {
        case .heartAndSoul:
            delegate?.setHeartAndSoul(value: true)
        case .jingleBells:
            delegate?.setJingleBells(value: true)
            generateSnow()
        }
        
        PianoKey.isSpeakerEnabled = false
        
        var i = 0
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { (timer) in
            if notes[i] != .pause {
                if let pianoKey = self.childNode(withName: notes[i].rawValue) as? PianoKey {
                    pianoKey.handleTouch()
                    if chosenSong == .heartAndSoul {
                        self.generateEmitter(position: CGPoint(x: pianoKey.frame.midX,
                                                               y: pianoKey.frame.maxY))
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                        pianoKey.handleEndOfTouch()
                    })
                }
                
                if i == notes.count - 1 {
                    self.delegate?.setHeartAndSoul(value: false)
                    self.delegate?.setJingleBells(value: false)
                    timer.invalidate()
                }
            }
            i += 1
        }
    }
    
    public func setupKeys() {
        var endingPoint: CGFloat!
        var topPoint: CGFloat!
        var i = 0
        
        for (index, whiteNote) in whiteNotes.enumerated() {
            let position = CGPoint(x: 0 + CGFloat(index) * (WhitePianoKey.width + 1.0),
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
                                                  position: CGPoint.init(x: whitePianoKey.frame.maxX - BlackPianoKey.width/2,
                                                                         y: topPoint - BlackPianoKey.height - 5.0),
                                                  sound: noteSounds[blackNotes[i].rawValue]!)
                blackPianoKey.zPosition = 1.0
                self.addChild(blackPianoKey)
                i += 1
            }
            
            self.addChild(whitePianoKey)
        }
        setupPiano(CGRect(x: 0 - 1,
                          y: topPoint - 20,
                          width: endingPoint - 0 + 1,
                          height: 20))
    }
    
    private func mapSounds() {
        for whiteNote in whiteNotes {
            noteSounds[whiteNote.rawValue] = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: whiteNote.rawValue,
                                                                                            withExtension: "mp3",
                                                                                            subdirectory: "sounds")!)
        }
        
        for blackNote in blackNotes {
            noteSounds[blackNote.rawValue] = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: blackNote.rawValue,
                                                                                            withExtension: "mp3",
                                                                                            subdirectory: "sounds")!)
        }
        
        for noteSound in noteSounds.values {
            noteSound.volume = 0.4
            noteSound.prepareToPlay()
        }
    }
    
    private func setupPiano(_ rect: CGRect) {
        let piano = SKShapeNode()
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 5.0, height: 5.0)).cgPath
        piano.path = path
        piano.fillColor = UIColor.piano
        piano.strokeColor = UIColor.piano
        piano.zPosition = 2.0
        self.addChild(piano)
    }
    
    private func generateEmitter(position: CGPoint) {
        let emitter = SKEmitterNode(fileNamed: "HeartParticle")!
        emitter.numParticlesToEmit = 7
        emitter.position = position
        emitter.zPosition = -1.0
        
        let fadeAction = SKAction.fadeAlpha(to: 0, duration: 1.0)
        let actionSequence = [fadeAction, SKAction.removeFromParent()]
        emitter.run(SKAction.sequence(actionSequence))
        self.addChild(emitter)
    }
    
    private func generateSnow() {
        snowEmitter = SKEmitterNode(fileNamed: "SnowParticle")!
        snowEmitter?.position = CGPoint(x: 300, y: 500)
        self.addChild(snowEmitter!)
    }
}
