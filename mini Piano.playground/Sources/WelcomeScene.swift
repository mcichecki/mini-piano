import Foundation
import SpriteKit

public class WelcomeScene: SKScene {
    
    var speechSynthesizer: SpeechSynthesizer!
    
    private var sentences: [String] = []
    private var noteEmitter: SKEmitterNode?
    
    private let welcomeView: UIView = UIView(frame: CGRect.zero)
    private let speechLabel: UILabel = UILabel(frame: CGRect.zero)
    private let skipButton: UIButton = UIButton(frame: CGRect.zero)
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.darkBackground
        setupWelcomeScene()
    }
    
    private func setupWelcomeScene() {
        let frameWidth = self.view!.frame.width
        let frameHeight = self.view!.frame.height
        
        welcomeView.frame = CGRect(x: frameWidth/2,
                                   y: 0,
                                   width: 0,
                                   height: frameHeight)
        welcomeView.backgroundColor = UIColor.background
        self.view!.addSubview(welcomeView)
        
        speechLabel.frame = CGRect(x: 0, y: 100, width: 500, height: 40)
        speechLabel.center.x = self.view!.center.x
        speechLabel.textAlignment = .center
        speechLabel.font = speechLabel.font.withSize(32.0)
        speechLabel.textColor = UIColor.white
        self.view!.addSubview(speechLabel)
        
        skipButton.frame = CGRect(x: 0, y: frameHeight, width: 50, height: 30)
        skipButton.setTitle("skip", for: .normal)
        skipButton.setTitleColor(UIColor.darkGray, for: .normal)
        skipButton.center.x = self.view!.center.x
        skipButton.contentHorizontalAlignment = .center
        skipButton.addTarget(self, action: #selector(skipScene), for: .touchUpInside)
        skipButton.isEnabled = false
        self.view!.addSubview(skipButton)
        
        
        UIView.animate(withDuration: 2.0, animations: {
            self.welcomeView.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
            self.skipButton.frame = CGRect(origin: CGPoint(x: frameWidth/2 - 25, y: frameHeight - 50),
                                           size: self.skipButton.frame.size)
            
        }) { (_) in
            self.backgroundColor = UIColor.background
            self.welcomeView.removeFromSuperview()
            self.startIntroduction()
            self.setupNoteEmitter()
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
            "Today you can also see how to play",
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
        self.noteEmitter!.particleBirthRate = 0.0
        self.noteEmitter = nil
        UIView.animate(withDuration: 0.5, animations: {
            self.skipButton.alpha = 0.0
            if self.speechLabel.alpha > 0.0 {
                self.speechLabel.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                self.speechLabel.alpha = 0.0
            }
            self.speechSynthesizer.stop()
        }) { (_) in
            self.view?.presentScene(scene, transition: horizontalTransition)
            self.speechLabel.removeFromSuperview()
            self.speechSynthesizer = nil
        }
    }
    
    private func setupNoteEmitter() {
        noteEmitter = SKEmitterNode(fileNamed: "NoteParticle")!
        noteEmitter!.position = CGPoint(x: self.view!.frame.maxX, y: 0)
        noteEmitter!.zPosition = -1.0
        self.addChild(noteEmitter!)
    }
}

extension WelcomeScene: SpeechSynthesizerDelegate {
    func changeLabel(i: Int) {
        speechLabel.text = sentences[i]
        switch i {
        case 0:
            skipButton.isEnabled = true
            skipButton.setTitleColor(UIColor.white, for: .normal)
        case sentences.count - 1:
            self.skipButton.removeFromSuperview()
            UIView.animate(withDuration: 1.5, delay: 0.0, options: [], animations: {
                self.speechLabel.transform = CGAffineTransform(scaleX: 20.0, y: 20.0)
                self.speechLabel.alpha = 0.0
            }, completion: { _ in
                self.skipScene()
                return
            })
        default:
            return
        }
    }
}
