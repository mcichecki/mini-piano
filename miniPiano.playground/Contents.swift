import UIKit
import PlaygroundSupport
import SpriteKit
//import AVFoundation

let sceneSize = CGSize(width: 600.0, height: 350.0)
let view = SKView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: sceneSize))
let welcomeScene = WelcomeScene(size: sceneSize)

view.presentScene(welcomeScene)
PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

