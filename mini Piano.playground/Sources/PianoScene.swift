import Foundation
import SpriteKit

public class PianoScene: SKScene {
    private var timer: Timer!
    private var piano: Piano!
    
    // UI
    private var playHeartAndSoulButton = UIButton(frame: CGRect())
    private var playJingleBellsButton = UIButton(frame: CGRect())
    private var widthLabel = UILabel(frame: CGRect())
    private var heightLabel = UILabel(frame: CGRect())
    private var widthButton: SelectButton!
    private var heightButton: SelectButton!
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.background
        
        let startingPoint: CGFloat = self.view!.frame.width/2 - 7 * WhitePianoKey.width - 7
        piano = Piano(timer: Timer())
        piano.position = CGPoint(x: startingPoint, y: 0)
        piano.delegate = self
        self.addChild(piano)
        setupUIComponents()
    }
    
    private func setupUIComponents() {
        playHeartAndSoulButton.addTarget(self, action: #selector(playHeartAndSoul(sender:)),
                                         for: .touchUpInside)
        playHeartAndSoulButton.frame = CGRect(x: 10, y: view!.frame.height - 40, width: 240, height: 40)
        playHeartAndSoulButton.contentHorizontalAlignment = .left
        playHeartAndSoulButton.setTitle("▶ play Heart and Soul ❤️", for: .normal)
        playHeartAndSoulButton.setTitleColor(UIColor.white, for: .normal)
        playHeartAndSoulButton.tag = Piano.Song.heartAndSoul.rawValue
        self.view!.addSubview(playHeartAndSoulButton)
        
        playJingleBellsButton.addTarget(self, action: #selector(playJingleBells(sender:)),
                                        for: .touchUpInside)
        playJingleBellsButton.frame = CGRect(x: 10, y: view!.frame.height - 80, width: 240, height: 40)
        playJingleBellsButton.contentHorizontalAlignment = .left
        playJingleBellsButton.setTitle("▶ play Jingle Bells 🎄", for: .normal)
        playJingleBellsButton.setTitleColor(UIColor.white, for: .normal)
        playJingleBellsButton.tag = Piano.Song.jingleBells.rawValue
        self.view!.addSubview(playJingleBellsButton)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            let scaleTransform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.playJingleBellsButton.transform = scaleTransform
            self.playHeartAndSoulButton.transform = scaleTransform
        }, completion: nil)
        
        widthButton = SelectButton(handleClick: {
            if self.widthButton.isClicked {
                WhitePianoKey.width = 40.0
                BlackPianoKey.width = 28.0
            } else {
                WhitePianoKey.width = 32.0
                BlackPianoKey.width = 20.0
            }
            self.piano.removeFromParent()
            self.piano.removeAllChildren()
            let startingPoint: CGFloat = self.view!.frame.width/2 - 7 * WhitePianoKey.width - 7
            self.piano.position = CGPoint(x: startingPoint, y: 0)
            self.piano.setupKeys()
            self.addChild(self.piano)
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
        
        heightButton = SelectButton(handleClick: {
            if self.heightButton.isClicked {
                WhitePianoKey.height = 156.0
                BlackPianoKey.height = 92.0
            } else {
                WhitePianoKey.height = 110.0
                BlackPianoKey.height = 60.0
            }
            self.piano.removeFromParent()
            self.piano.removeAllChildren()
            let startingPoint: CGFloat = self.view!.frame.width/2 - 7 * WhitePianoKey.width - 7
            self.piano.position = CGPoint(x: startingPoint, y: 0)
            self.piano.setupKeys()
            self.addChild(self.piano)
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
            .G1, .G1, .B1, .D2, .pause,
            .C2, .C2, .C2, .pause, .pause,
            .C2, .B1, .A1, .B1, .C2, .D2, .pause,
            .E2, .E2, .E2, .pause,
            .E2, .D2, .C2, .D2, .E2, .F2, .pause,
            .G2, .pause, .C2, .pause, .A2, .pause,
            .G2, .F2, .E2, .D2, .C2
        ]
        
        piano.playSong(with: heartAndSoulNotes,
                       speed: 0.45,
                       chosenSong: Piano.Song(rawValue: sender.tag)!)
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
        
        piano.playSong(with: jingleBellsNotes,
                       speed: 0.35,
                       chosenSong: Piano.Song(rawValue: sender.tag)!)
    }
    
    @objc private func sizePressed() {
        WhitePianoKey.width = 40
        removeAllChildren()
        piano.setupKeys()
    }
}

extension PianoScene: PianoDelegate {
    public func setJingleBells(value: Bool) {
        playJingleBellsButton.setTitle(value ?
            "◼︎ stop Jingle Bells 🎄" :
            "▶ play Jingle Bells 🎄", for: .normal)
        self.backgroundColor = value ? UIColor.jingleBells : UIColor.background
        if piano.snowEmitter != nil && !value {
            piano.snowEmitter!.particleLifetime = 0.0
            piano.snowEmitter!.removeFromParent()
        }
        widthButton.isEnabled = !value
        heightButton.isEnabled = !value
        Piano.isJingleBellsPlaying = value
    }
    
    public func setHeartAndSoul(value: Bool) {
        playHeartAndSoulButton.setTitle(value ?
            "◼︎ stop Heart and Soul ❤️" :
            "▶ play Heart and Soul ❤️", for: .normal)
        widthButton.isEnabled = !value
        heightButton.isEnabled = !value
        self.backgroundColor = value ? UIColor.heartAndSoul : UIColor.background
        Piano.isHeartAndSoulPlaying = value
    }
}
