//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import SpriteKit
import AVFoundation

public enum Note: String {
    case C1, D1b, D1, E1, E1b, F1, G1, G1b, A1, A1b, H1, H1b,
    C2, D2b, D2, E2, E2b, F2, G2, G2b, A2, A2b, H2, H2b,
    pause
}

public enum Song: Int {
    case heartAndSoul, jingleBells
}

public class PianoScene: SKScene {
    
    private let whiteNotes: [Note] = [.C1, .D1, .E1, .F1, .G1, .A1, .H1,
                                      .C2, .D2, .E2, .F2, .G2, .A2, .H2]
    
    private let blackNotes: [Note] = [.D1b, .E1b, .G1b, .A1b, .H1b,
                                      .D2b, .E2b, .G2b, .A2b, .H2b]
    
    private var noteSounds: [String: AVAudioPlayer] = [:]
    
    private var timer: Timer?
    
    private var snowEmitter: SKEmitterNode?
    
    private var isHeartAndSoulPlaying: Bool = false {
        willSet {
            playHeartAndSoulButton.setTitle(newValue ? "◼︎ stop Heart and Sould": "▶ play Heart and Soul",
                                            for: .normal)
            widthSwitch.isEnabled = !newValue
            heightSwitch.isEnabled = !newValue
            self.backgroundColor = newValue ? UIColor.heartPink : UIColor.background
        }
    }
    
    private var isJingleBellsPlaying: Bool = false {
        willSet {
            playJingleBellsButton.setTitle(newValue ? "◼︎ stop Jingle Bells": "▶ play Jingle Bells",
                                           for: .normal)
            self.backgroundColor = newValue ? UIColor.jingleBells : UIColor.background
            if snowEmitter != nil && !newValue {
                snowEmitter!.particleLifetime = 0.0
                snowEmitter!.removeFromParent()
            }
        }
    }
    
    // UI
    private var playHeartAndSoulButton = UIButton(frame: CGRect())
    private var playJingleBellsButton = UIButton(frame: CGRect())
    private var widthSwitch = UISwitch(frame: CGRect())
    private var heightSwitch = UISwitch(frame: CGRect())
    private var widthLabel = UILabel(frame: CGRect())
    private var heightLabel = UILabel(frame: CGRect())
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.background
        mapSounds()
        setupKeys()
        setupUIComponents()
    }
    
    private func setupKeys() {
        let startingPoint: CGFloat = self.view!.frame.width/2 - 7 * WhitePianoKey.width - 7
        var endingPoint: CGFloat!
        var topPoint: CGFloat!
        var i = 0
        
        for (index, whiteNote) in whiteNotes.enumerated() {
            let position = CGPoint(x: startingPoint + CGFloat(index) * (WhitePianoKey.width + 1.0),
                                   y: 80)
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
    
    private func setupUIComponents() {
        playHeartAndSoulButton.addTarget(self, action: #selector(playHeartAndSoul(sender:)),
                                         for: .touchUpInside)
        playHeartAndSoulButton.frame = CGRect(x: 10, y: view!.frame.height - 40, width: 200, height: 40)
        playHeartAndSoulButton.contentHorizontalAlignment = .left
        playHeartAndSoulButton.setTitle("▶ play Heart and Soul", for: .normal)
        playHeartAndSoulButton.setTitleColor(UIColor.white, for: .normal)
        playHeartAndSoulButton.tag = Song.heartAndSoul.rawValue
        self.view!.addSubview(playHeartAndSoulButton)
        
        playJingleBellsButton.addTarget(self, action: #selector(playJingleBells(sender:)),
                                        for: .touchUpInside)
        playJingleBellsButton.frame = CGRect(x: 10, y: view!.frame.height - 70, width: 200, height: 40)
        playJingleBellsButton.contentHorizontalAlignment = .left
        playJingleBellsButton.setTitle("▶ play Jingle Bells", for: .normal)
        playJingleBellsButton.setTitleColor(UIColor.white, for: .normal)
        playJingleBellsButton.tag = Song.jingleBells.rawValue
        self.view!.addSubview(playJingleBellsButton)
        
        widthSwitch.addTarget(self,
                              action: #selector(widthValueChanged(widthSwitch:)),
                              for: .valueChanged)
        widthSwitch.frame = CGRect(x: self.frame.width - 55,
                                   y: 0,
                                   width: 40,
                                   height: 0)
        widthSwitch.center.y = playHeartAndSoulButton.center.y
        widthSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        widthSwitch.onTintColor = UIColor.switchControl
        self.view!.addSubview(widthSwitch)
        
        heightSwitch.addTarget(self,
                               action: #selector(heightValueChanged(heightSwitch:)),
                               for: .valueChanged)
        heightSwitch.center.x = widthSwitch.center.x
        heightSwitch.center.y = playJingleBellsButton.center.y
        heightSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        heightSwitch.onTintColor = UIColor.switchControl
        self.view!.addSubview(heightSwitch)
        
        widthLabel.frame = CGRect(x: widthSwitch.frame.minX - 150,
                                  y: 0,
                                  width: 140,
                                  height: 30)
        widthLabel.center.y = widthSwitch.center.y
        widthLabel.text = "increase width"
        widthLabel.textColor = UIColor.white
        widthLabel.textAlignment = .right
        self.view?.addSubview(widthLabel)
        
        heightLabel.frame = CGRect(x: heightSwitch.frame.minX - 150,
                                   y: 0,
                                   width: 140,
                                   height: 30)
        heightLabel.center.y = heightSwitch.center.y
        heightLabel.textColor = UIColor.white
        heightLabel.text = "increase height"
        heightLabel.textAlignment = .right
        self.view?.addSubview(heightLabel)
    }
    
    @objc private func playHeartAndSoul(sender: UIButton) {
        let heartAndSoulNotes: [Note] = [
            .C2, .C2, .E2, .G2,
            .A1, .A1, .C2, .E2,
            .F1, .F1, .A1, .C2,
            .G1, .G1, .H1, .D2, .pause,
            .C2, .C2, .C2, .pause, .pause,
            .C2, .H1, .A1, .H1, .C2, .D2, .pause,
            .E2, .E2, .E2, .pause,
            .E2, .D2, .C2, .D2, .E2, .F2, .pause,
            .G2, .pause, .C2, .pause, .A2, .pause,
            .G2, .F2, .E2, .D2, .C2
        ]
        
        playSong(with: heartAndSoulNotes,
                 speed: 0.5,
                 chosenSong: Song(rawValue: sender.tag)!)
    }
    
    @objc private func playJingleBells(sender: UIButton) {
        let jingleBellsNotes: [Note] = [
            .E2, .E2, .E2, .pause,
            .E2, .E2, .E2, .pause,
            .E2, .G2, .C2, .D2,
            .E2, .pause, .pause, .pause,
            .F2, .F2, .F2, .F2,
            .F2, .E2, .E2, .E2, .pause,
            .E2, .D2, .D2, .E2,
            .D2, .pause, .G2, .pause,
            .E2, .E2, .E2, .pause,
            .E2, .E2, .E2, .pause,
            .E2, .G2, .C2, .D2,
            .E2, .pause, .pause, .pause,
            .F2, .F2, .F2, .F2,
            .F2, .E2, .E2, .E2, .pause,
            .G2, .G2, .F2, .D2, .C2
        ]
        
        playSong(with: jingleBellsNotes,
                 speed: 0.3,
                 chosenSong: Song(rawValue: sender.tag)!)
    }
    
    private func playSong(with notes: [Note], speed: TimeInterval, chosenSong: Song) {
        if isHeartAndSoulPlaying || isJingleBellsPlaying {
            timer?.invalidate()
            timer = nil
            isHeartAndSoulPlaying = false
            isJingleBellsPlaying = false
            return
        }
        
        switch chosenSong {
        case .heartAndSoul:
            isHeartAndSoulPlaying = true
        case .jingleBells:
            isJingleBellsPlaying = true
            generateSnow()
        }
        
        var i = 0
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { (timer) in
            if notes[i] != .pause {
                
                if let pianoKey = self.childNode(withName: notes[i].rawValue) as? PianoKey {
                    pianoKey.handleTouch()
                    if chosenSong == .heartAndSoul {
                        self.generateEmitter(position: CGPoint(x: pianoKey.frame.midX,
                                                               y: pianoKey.frame.maxY))
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        pianoKey.handleEndOfTouch()
                    })
                }
                
                if i == notes.count - 1 {
                    self.isHeartAndSoulPlaying = false
                    self.isJingleBellsPlaying = false
                    timer.invalidate()
                }
            }
            i += 1
        }
    }
    
    @objc private func sizePressed() {
        WhitePianoKey.width = 40
        removeAllChildren()
        setupKeys()
    }
    
    @objc private func widthValueChanged(widthSwitch: UISwitch) {
        if widthSwitch.isOn {
            WhitePianoKey.width = 40.0
            BlackPianoKey.width = 28.0
        } else {
            WhitePianoKey.width = 32.0
            BlackPianoKey.width = 20.0
        }
        removeAllChildren()
        setupKeys()
    }
    
    @objc private func heightValueChanged(heightSwitch: UISwitch) {
        if heightSwitch.isOn {
            WhitePianoKey.height = 156.0
            BlackPianoKey.height = 92.0
        } else {
            WhitePianoKey.height = 110.0
            BlackPianoKey.height = 60.0
        }
        removeAllChildren()
        setupKeys()
    }
    
    private func generateEmitter(position: CGPoint) {
        let emitter = SKEmitterNode(fileNamed: "HeartParticle")!
        emitter.particleBirthRate = 10.0
        emitter.numParticlesToEmit = 7
        emitter.position = position
        emitter.zPosition = -1.0
        
        let moveAction = SKAction.move(by: CGVector.init(dx: 0, dy: 100.0), duration: 1.0)
        let actionSequence = [moveAction, SKAction.removeFromParent()]
        emitter.run(SKAction.sequence(actionSequence))
        self.addChild(emitter)
    }
    
    private func generateSnow() {
        snowEmitter = SKEmitterNode(fileNamed: "SnowParticle")!
        snowEmitter!.position = CGPoint(x: self.view!.frame.width/2, y: self.frame.maxY)
        self.addChild(snowEmitter!)
    }
}

// # #  # ###  3
// ## ##  ###
public class WelcomeScene: SKScene {
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    private let leftView: UIView = UIView(frame: CGRect.zero)
    private let rightView: UIView = UIView(frame: CGRect.zero)
    private let speechLabel: UILabel = UILabel(frame: CGRect.zero)
    private let skipButton: UIButton = UIButton(frame: CGRect.zero)
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.background

        setupWelcomeScene()
    }
    
    private func setupWelcomeScene() {
        let frameWidth = self.view!.frame.width
        let frameHeight = self.view!.frame.height
        
        leftView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: frameWidth/2,
                                    height: frameHeight)
        leftView.backgroundColor = UIColor.darkBackground
        
        rightView.frame = CGRect(x: frameWidth/2,
                                    y: 0,
                                    width: frameWidth/2,
                                    height: frameHeight)
        rightView.backgroundColor = UIColor.darkBackground
        
        
        
        speechLabel.frame = CGRect(x: frameWidth/2, y: frameHeight/2, width: 1, height: 1)
        speechLabel.textAlignment = .center
        speechLabel.text = "SPEECH"
        
        skipButton.frame = CGRect(x: frameWidth/2-25, y: frameHeight, width: 50, height: 30)
        skipButton.setTitle("skip", for: .normal)
        skipButton.contentHorizontalAlignment = .center
        skipButton.addTarget(self, action: #selector(skipScene), for: .touchUpInside)
        
        self.view!.addSubview(leftView)
        self.view!.addSubview(rightView)
        self.view!.addSubview(skipButton)
        self.view!.addSubview(speechLabel)
        
        UIView.animate(withDuration: 2.0, animations: {
            self.leftView.frame = CGRect(x: 0, y: 0, width: 0, height: frameHeight)
            self.rightView.frame = CGRect(x: frameWidth, y: 0, width: 0, height: frameHeight)
            self.speechLabel.frame = CGRect(origin: self.speechLabel.frame.origin, size: CGSize(width: 400, height: 30))
            self.skipButton.frame = CGRect(origin: CGPoint(x: frameWidth/2 - 25, y: frameHeight - 50), size: self.skipButton.frame.size)

        }) { (_) in
            self.leftView.removeFromSuperview()
            self.rightView.removeFromSuperview()
            self.startIntroduction()
        }
    }
    
    private func startIntroduction() {
        let speechSynthesizer = AVSpeechSynthesizer()
        let attributedString = NSAttributedString(string: "This is a piano scene")
        let speechUtterance = AVSpeechUtterance(attributedString: attributedString)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @objc private func skipScene() {
        let horizontalTransition = SKTransition.push(with: .down, duration: 1.0)
        let scene = PianoScene(size: self.view!.frame.size)
        UIView.animate(withDuration: 0.5, animations: {
            self.skipButton.alpha = 0.0
            self.speechLabel.alpha = 0.0
        }) { (_) in
            self.view?.presentScene(scene, transition: horizontalTransition)
            self.skipButton.removeFromSuperview()
            self.speechLabel.removeFromSuperview()
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
    private var keyPosition: CGPoint = CGPoint()
    
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
    }
    
    public func handleEndOfTouch() {
        fatalError("Must be implemented by the subclass")
    }
    
    func showNote() {
        let noteLabel = SKLabelNode(fontNamed: "SFCompactText-Regular")
        let moveUpAction = SKAction.moveBy(x: 0, y: 200, duration: 1.1)
        let increaseSizeAction = SKAction.scale(by: 2.0, duration: 1.0)
        let fadeAction = SKAction.fadeAlpha(to: 0, duration: 1.0)
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
        noteLabel.fontColor = UIColor.white
        noteLabel.zPosition = -1.0
        noteLabel.name = "note"
        
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
}

public class WhitePianoKey: PianoKey {
    public static var height: CGFloat = 110.0
    public static var width: CGFloat = 32.0
    
    public override func keyPath(_ position: CGPoint) -> CGPath {
        let keyRect = CGRect(origin: position,
                             size: CGSize(width: WhitePianoKey.width,
                                          height: WhitePianoKey.height))
        return UIBezierPath(roundedRect: keyRect, cornerRadius: 5.0).cgPath
    }
    
    public override func handleTouch() {
        super.handleTouch()
        self.fillColor = UIColor.whiteKeyPressed
    }
    
    public override func handleEndOfTouch() {
        self.fillColor = UIColor.white
    }
}

public class BlackPianoKey: PianoKey {
    public static var height: CGFloat = 60.0
    public static var width: CGFloat = 20.0
    
    public override var keyColor: UIColor! {
        return UIColor.black
    }
    
    public override func keyPath(_ position: CGPoint) -> CGPath {
        let keyRect = CGRect(origin: position,
                             size: CGSize(width: BlackPianoKey.width,
                                          height: BlackPianoKey.height))
        
        return UIBezierPath(roundedRect: keyRect,
                            cornerRadius: 5.0).cgPath
    }
    
    public override func handleTouch() {
        super.handleTouch()
        self.fillColor = UIColor.blackKeyPressed
    }
    
    public override func handleEndOfTouch() {
        self.fillColor = UIColor.blackKey
    }
}

extension UIColor {
    static var piano = UIColor(red: 166/255.0, green: 41/255.0, blue: 35/255.0, alpha: 1.0)
    static var whiteKeyPressed = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0)
    static var blackKey = UIColor(red: 3/255.0, green: 3/255.0, blue: 3/255.0, alpha: 1.0)
    static var blackKeyPressed = UIColor(red: 43/255.0, green: 43/255.0, blue: 43/255.0, alpha: 1.0)
    static var switchControl = UIColor(red: 167/255.0, green: 239/255.0, blue: 139/255.0, alpha: 1.0)
    static var background = UIColor(red: 82/255.0, green: 177/255.0, blue: 90/255.0, alpha: 1.0)
    static var darkBackground = UIColor(red: 59/255.0, green: 63/255.0, blue: 66/255.0, alpha: 1.0)
    static var heartPink = UIColor(red: 155/255.0, green: 80/255.0, blue: 166/255.0, alpha: 1.0)
    static var jingleBells = UIColor(red: 25/255.0, green: 42/255.0, blue: 95/255.0, alpha: 1.0)
}

//let pianoScene = PianoScene(size: CGSize(width: 600.0, height: 350.0))
let welcomeScene = WelcomeScene(size: CGSize(width: 600.0, height: 350.0))
let view = SKView(frame: CGRect(x: 0, y: 100, width: 600.0, height: 350.0))

view.presentScene(welcomeScene)
PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

//Piano is a powerful instrument. With only two octaves you can play popular songs, so let's see how

