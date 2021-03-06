import Foundation
import SpriteKit

public class PianoScene: SKScene {
    private var timer: Timer!
    private var piano: Piano!
    
    private var playHeartAndSoulButton = UIButton(frame: CGRect())
    private var playJingleBellsButton = UIButton(frame: CGRect())
    private var widthButton: SelectButton!
    private var widthLabel = UILabel(frame: CGRect())
    private var heightButton: SelectButton!
    private var heightLabel = UILabel(frame: CGRect())
    private var synthesizerButton: SelectButton!
    private var synthesizerLabel = UILabel(frame: CGRect())
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.background
        
        let startingPoint: CGFloat = self.view!.frame.width/2 - 7 * WhitePianoKey.width - 7
        piano = Piano(timer: Timer())
        piano.position = CGPoint(x: startingPoint, y: 40)
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
        
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: [.repeat, .autoreverse, .allowUserInteraction],
                       animations: {
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
            self.piano.position = CGPoint(x: startingPoint, y: 40)
            self.piano.setupKeys()
            self.addChild(self.piano)
        })
        widthButton.frame.origin = CGPoint(x: self.view!.frame.width - 50, y: 0)
        widthButton.center.y = playJingleBellsButton.center.y
        self.view!.addSubview(widthButton)
        
        widthLabel.frame = CGRect(origin: CGPoint(x: widthButton.frame.minX - 130, y: 0),
                                  size: CGSize(width: 120.0, height: 20.0))
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
            self.piano.position = CGPoint(x: startingPoint, y: 40)
            self.piano.setupKeys()
            self.addChild(self.piano)
        })
        
        heightButton.frame.origin = CGPoint(x: self.view!.frame.width - 50, y: 0)
        heightButton.center.y = playHeartAndSoulButton.center.y
        heightLabel.frame = CGRect(origin: CGPoint(x: widthButton.frame.minX - 130, y: 0),
                                   size: CGSize(width: 120.0, height: 20.0))
        heightLabel.center.y = heightButton.center.y
        heightLabel.text = "increase height"
        heightLabel.textColor = UIColor.white
        heightLabel.textAlignment = .right
        
        self.view!.addSubview(heightLabel)
        self.view!.addSubview(heightButton)
        
        synthesizerButton = SelectButton(handleClick: {
            PianoKey.isSpeakerEnabled = self.synthesizerButton.isClicked
        })
        synthesizerButton.frame.origin = CGPoint(x: self.view!.frame.width - 50,
                                                 y: heightButton.frame.minY - 80)
        synthesizerLabel.frame = CGRect(origin: CGPoint(x: widthButton.frame.minX - 130, y: 0),
                                        size: CGSize(width: 120.0, height: 20.0))
        synthesizerLabel.center.y = synthesizerButton.center.y
        synthesizerLabel.text = "enable speech"
        synthesizerLabel.textColor = UIColor.white
        synthesizerLabel.textAlignment = .right
        
        self.view!.addSubview(synthesizerButton)
        self.view!.addSubview(synthesizerLabel)
    }
    
    @objc private func playHeartAndSoul(sender: UIButton) {
        let heartAndSoulNotes: [Note] = [
            .C4, .C4, .E4, .E4,
            .A3, .A3, .C4, .C4,
            .D4, .D4, .F4, .F4,
            .G3, .G3, .B3, .B3,
            .C4, .pause, .C4, .pause,
            .C4, .pause, .pause, .pause,
            .pause, .C4, .B3, .A3,
            .B3, .C4, .D4, .pause,
            .E4, .pause, .E4, .pause,
            .E4, .pause, .pause, .pause,
            .pause, .E4, .D4, .C4,
            .D4, .E4, .F4, .pause,
            .G4, .pause, .pause, .pause,
            .C4, .pause, .pause, .A4,
            .pause, .pause, .G4,
            .F4, .E4, .D4, .C4
        ]
        
        if synthesizerButton.isClicked {
            synthesizerButton.isClicked = false
        }
        piano.playSong(with: heartAndSoulNotes,
                       speed: 0.35,
                       chosenSong: Piano.Song(rawValue: sender.tag)!)
    }
    
    @objc private func playJingleBells(sender: UIButton) {
        let jingleBellsNotes: [Note] = [
            .E4, .E4, .E4, .pause,
            .E4, .E4, .E4, .pause,
            .E4, .G4, .C4, .D4,
            .E4, .pause, .pause, .pause,
            .F4, .F4, .F4, .F4,
            .F4, .E4, .E4, .E4, .pause,
            .E4, .D4, .D4, .E4,
            .D4, .pause, .G4, .pause,
            .E4, .E4, .E4, .pause,
            .E4, .E4, .E4, .pause,
            .E4, .G4, .C4, .D4,
            .E4, .pause, .pause, .pause,
            .F4, .F4, .F4, .F4,
            .F4, .E4, .E4, .E4, .pause,
            .G4, .G4, .F4, .D4, .C4
        ]
        
        if synthesizerButton.isClicked {
            synthesizerButton.isClicked = false
        }
        
        piano.playSong(with: jingleBellsNotes,
                       speed: 0.35,
                       chosenSong: Piano.Song(rawValue: sender.tag)!)
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
        synthesizerButton.isEnabled = !value
        Piano.isJingleBellsPlaying = value
    }
    
    public func setHeartAndSoul(value: Bool) {
        playHeartAndSoulButton.setTitle(value ?
            "◼︎ stop Heart and Soul ❤️" :
            "▶ play Heart and Soul ❤️", for: .normal)
        widthButton.isEnabled = !value
        heightButton.isEnabled = !value
        synthesizerButton.isEnabled = !value
        self.backgroundColor = value ? UIColor.heartAndSoul : UIColor.background
        Piano.isHeartAndSoulPlaying = value
    }
}
