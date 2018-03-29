import Foundation
import UIKit

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
