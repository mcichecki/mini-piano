import Foundation
import UIKit

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
