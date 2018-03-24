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
            playHeartAndSoulButton.setTitle(newValue ? "◼︎ stop Heart and Sould ❤️": "▶ play Heart and Soul ❤️",
                                            for: .normal)
            widthButton.isEnabled = !newValue
            heightButton.isEnabled = !newValue
            self.backgroundColor = newValue ? UIColor.heartPink : UIColor.background
        }
    }
    
    private var isJingleBellsPlaying: Bool = false {
        willSet {
            playJingleBellsButton.setTitle(newValue ? "◼︎ stop Jingle Bells 🎄": "▶ play Jingle Bells 🎄",
                                           for: .normal)
            self.backgroundColor = newValue ? UIColor.jingleBells : UIColor.background
            if snowEmitter != nil && !newValue {
                snowEmitter!.particleLifetime = 0.0
                snowEmitter!.removeFromParent()
            }
            widthButton.isEnabled = !newValue
            heightButton.isEnabled = !newValue
        }
    }
    
    // UI
    private var playHeartAndSoulButton = UIButton(frame: CGRect())
    private var playJingleBellsButton = UIButton(frame: CGRect())
    private var widthLabel = UILabel(frame: CGRect())
    private var heightLabel = UILabel(frame: CGRect())
    private var widthButton: ConfirmButton!
    private var heightButton: ConfirmButton!
    
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
        playHeartAndSoulButton.frame = CGRect(x: 10, y: view!.frame.height - 40, width: 240, height: 40)
        playHeartAndSoulButton.contentHorizontalAlignment = .left
        playHeartAndSoulButton.setTitle("▶ play Heart and Soul ❤️", for: .normal)
        playHeartAndSoulButton.setTitleColor(UIColor.white, for: .normal)
        playHeartAndSoulButton.tag = Song.heartAndSoul.rawValue
        self.view!.addSubview(playHeartAndSoulButton)
        
        playJingleBellsButton.addTarget(self, action: #selector(playJingleBells(sender:)),
                                        for: .touchUpInside)
        playJingleBellsButton.frame = CGRect(x: 10, y: view!.frame.height - 80, width: 240, height: 40)
        playJingleBellsButton.contentHorizontalAlignment = .left
        playJingleBellsButton.setTitle("▶ play Jingle Bells 🎄", for: .normal)
        playJingleBellsButton.setTitleColor(UIColor.white, for: .normal)
        playJingleBellsButton.tag = Song.jingleBells.rawValue
        self.view!.addSubview(playJingleBellsButton)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            let scaleTransform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.playJingleBellsButton.transform = scaleTransform
            self.playHeartAndSoulButton.transform = scaleTransform
        }, completion: nil)
        
        widthButton = ConfirmButton(handleClick: {
            if self.widthButton.isClicked {
                WhitePianoKey.width = 40.0
                BlackPianoKey.width = 28.0
            } else {
                WhitePianoKey.width = 32.0
                BlackPianoKey.width = 20.0
            }
            self.removeAllChildren()
            self.setupKeys()
        })
        widthButton.frame.origin = CGPoint(x: self.view!.frame.width - 50, y: 0)
        widthButton.center.y = playJingleBellsButton.center.y
        self.view!.addSubview(widthButton)
        
        widthLabel.frame = CGRect(origin: CGPoint(x: widthButton.frame.minX - 130, y: 0), size: CGSize(width: 120.0, height: 20.0))
        widthLabel.center.y = widthButton.center.y
        widthLabel.text = "increase width"
        widthLabel.textColor = UIColor.white
        widthLabel.textAlignment = .right
        self.view!.addSubview(widthLabel)
        
        heightButton = ConfirmButton(handleClick: {
            if self.heightButton.isClicked {
                WhitePianoKey.height = 156.0
                BlackPianoKey.height = 92.0
            } else {
                WhitePianoKey.height = 110.0
                BlackPianoKey.height = 60.0
            }
            self.removeAllChildren()
            self.setupKeys()
        })
        heightButton.frame.origin = CGPoint(x: self.view!.frame.width - 50, y: 0)
        heightButton.center.y = playHeartAndSoulButton.center.y
        heightLabel.frame = CGRect(origin: CGPoint(x: widthButton.frame.minX - 130, y: 0), size: CGSize(width: 120.0, height: 20.0))
        heightLabel.center.y = heightButton.center.y
        heightLabel.text = "increase height"
        heightLabel.textColor = UIColor.white
        heightLabel.textAlignment = .right
        self.view!.addSubview(heightLabel)
        
        self.view!.addSubview(heightButton)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
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
        snowEmitter!.position = CGPoint(x: self.view!.frame.width/2, y: self.frame.maxY)
        self.addChild(snowEmitter!)
    }
}

public class WelcomeScene: SKScene {
    
    var speechSynthesizer: SpeechSynthesizer!
    
    private var sentences: [String] = []
    
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
        self.view!.addSubview(leftView)
        
        rightView.frame = CGRect(x: frameWidth/2,
                                    y: 0,
                                    width: frameWidth/2,
                                    height: frameHeight)
        rightView.backgroundColor = UIColor.darkBackground
        self.view!.addSubview(rightView)
        
        speechLabel.frame = CGRect(x: 0, y: 100, width: 400, height: 40)
        speechLabel.center.x = self.view!.center.x
        speechLabel.textAlignment = .center
        speechLabel.font = speechLabel.font.withSize(26.0)
        speechLabel.textColor = UIColor.white
        self.view!.addSubview(speechLabel)
        
        skipButton.frame = CGRect(x: frameWidth/2-25, y: frameHeight, width: 50, height: 30)
        skipButton.setTitle("skip", for: .normal)
        skipButton.contentHorizontalAlignment = .center
        skipButton.addTarget(self, action: #selector(skipScene), for: .touchUpInside)
        skipButton.isEnabled = false
        self.view!.addSubview(skipButton)
        
        UIView.animate(withDuration: 2.0, animations: {
            self.leftView.frame = CGRect(x: 0, y: 0, width: 0, height: frameHeight)
            self.rightView.frame = CGRect(x: frameWidth, y: 0, width: 0, height: frameHeight)
            self.skipButton.frame = CGRect(origin: CGPoint(x: frameWidth/2 - 25, y: frameHeight - 50), size: self.skipButton.frame.size)

        }) { (_) in
            self.leftView.removeFromSuperview()
            self.rightView.removeFromSuperview()
            self.startIntroduction()
        }
    }
    
    private func startIntroduction() {
        sentences = [
            "Hello 🖐",
            "I would like to present ",
            "a mini Piano 🎹",
            "Piano is a powerful instrument",
            "With only two octaves 🎼",
            "you can play many songs 🎶",
            "Today you will play by yourself",
            "and see how to play",
            "Heart and Soul 💛",
            "and Jingle Bells 🎄",
            "Let's go!"
        ]
        
        speechSynthesizer = SpeechSynthesizer(sentences)
        speechSynthesizer.delegate = self
        speechSynthesizer.speak()
    }
    
    @objc private func skipScene() {
        let horizontalTransition = SKTransition.push(with: .down, duration: 1.0)
        let scene = PianoScene(size: self.view!.frame.size)
        UIView.animate(withDuration: 0.5, animations: {
            self.skipButton.alpha = 0.0
            self.speechLabel.alpha = 0.0
        }) { (_) in
            self.view?.presentScene(scene, transition: horizontalTransition)
            self.speechLabel.removeFromSuperview()
            self.speechSynthesizer.stop()
            self.speechSynthesizer = nil
        }
    }
}

extension WelcomeScene: SpeechSynthesizerDelegate {
    func changeLabel(i: Int) {
        if i == sentences.count - 1 {
            skipButton.removeFromSuperview()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.skipScene()
            })
        }
        skipButton.isEnabled = true
        speechLabel.text = sentences[i]
    }
}

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
    
    func setupSentences(_ sentences: [String]) {
        self.sentences = sentences
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
    static var button = UIColor(red: 202/255.0, green: 50/255.0, blue: 65/255.0, alpha: 1.0)
}

public class ConfirmButton: UIButton {
    
    var isClicked = false
    private var handleClick: () -> ()!
    
    public init(handleClick: @escaping () -> ()) {
        self.handleClick = handleClick
        super.init(frame: CGRect.zero)
        setupButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        self.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.layer.cornerRadius = 0.5 * self.frame.height
        self.clipsToBounds = true
        self.layer.borderWidth = 2.5
        self.layer.borderColor = UIColor.white.cgColor
        self.backgroundColor = UIColor.button
        self.setTitle("X", for: .normal)
        if let fontLabel = self.titleLabel?.font {
            self.titleLabel!.font = fontLabel.withSize(26.0)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isClicked = !isClicked
        self.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        self.backgroundColor = UIColor.button.withAlphaComponent(0.5)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.backgroundColor = UIColor.button.withAlphaComponent(isClicked ? 0.05 : 1.0)
        self.setTitle(isClicked ? "✓" : "X", for: .normal)
        handleClick()
    }
}

let sceneSize = CGSize(width: 600.0, height: 350.0)
let view = SKView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: sceneSize))
let welcomeScene = WelcomeScene(size: sceneSize)

view.presentScene(welcomeScene)
PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

