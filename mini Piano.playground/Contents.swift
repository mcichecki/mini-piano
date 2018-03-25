/*:
 # mini Piano 🎹
 
 mini Piano 🎹 is an interactive playground which you can use to play. Piano is a powerful instrument and with only two octaves you can see how to play two songs.
  
 ### List of songs
  * Heart and Soul ❤️
  * Jingle Bells 🎄
 
 You will know what song is currently playing by looking at the changing animation which adjusts to the current song 🙂
 
 When you press the piano's key you can see what tone has been generated.
 Single note is an exported music file of the piano recording. All interface elements have been created programmatically so user can easily manage the size of keys.
 */

import UIKit
import PlaygroundSupport
import SpriteKit

let sceneSize = CGSize(width: 600.0, height: 350.0)
let view = SKView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: sceneSize))
let welcomeScene = WelcomeScene(size: sceneSize)

view.presentScene(welcomeScene)
PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

