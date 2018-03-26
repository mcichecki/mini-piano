import Foundation
import UIKit

public class SelectButton: UIButton {
    
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
            self.titleLabel!.font = fontLabel.withSize(24.0)
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
