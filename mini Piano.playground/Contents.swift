/*:
 # mini Piano 🎹
 
 mini Piano 🎹 is an interactive playground which lets you play the piano. With only two octaves you can play many songs and mini Piano presents how to play two songs.
  
 ### List of songs
  * Heart and Soul ❤️
  * Jingle Bells 🎄
 
 You will know what song is currently playing by looking at the changing animation which adjusts to the current melody.
 
 When you press the piano's key you can see what tone was generated. It helps people who have never played the musical instrument.
 
 Single note is an exported music file of the piano recording. I used SKShapeNode subclass to draw piano interface so user can easily manage the size of keys.
 */
import UIKit
import PlaygroundSupport
import SpriteKit

let sceneSize = CGSize(width: 700, height: 450)
let view = SKView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: sceneSize))
let welcomeScene = WelcomeScene(size: sceneSize)

view.presentScene(welcomeScene)
PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

