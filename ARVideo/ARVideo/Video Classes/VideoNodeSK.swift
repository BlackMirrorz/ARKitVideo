//
//  VideoNodeSK.swift
//  Setup
//
//  Created by Josh Robbins on 02/03/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation
import SpriteKit

/// SCNNode Sublcass To Display An AVPlayer Using SpriteKit
class VideoNodeSK: SCNNode{
    
    var spriteKitScene: SKScene!
    var videoPlayerNode: SKVideoNode!
    var videoPlayer: AVPlayer!
    
    var numberOfButtons: Int = 0
    var BUTTON_SIZE: CGFloat = 0.4
    
    var controlValues = [String]()
    var buttonNames = [String]()
    
    var miniControlValues = ["Play", "Stop",  "Loop", "Mute"]
    var miniButtonNames = ["playButton", "stopButton", "loopOnButton", "muteOnButton"]
    
    var fullControlValues =  ["Play", "Stop", "Backwards", "Forwards", "Loop", "Mute"]
    var fullButtonNames = [ "playButton", "stopButton", "backwardsButton", "forwardButton", "loopOnButton", "muteOnButton"]
   
    var loopPlayBack = false
    var videoMuted = false

    var currentVideoIndex: Int = 0
    var videoArray = [String]()
    
    //--------------------
    //MARK: Initialization
    //--------------------
    
    /// Creates An SCNPlane With An SKScene For It's Material
    /// - Parameters:
    ///   - width: Optional CGFloat (Defaults To 3m)
    ///    -videoPath: [String]
    init(width: CGFloat = 3, videoPaths: [String]) {
        
        super.init()
        
        //1. Assign The Video Paths To Our Video Array
        videoArray = videoPaths
        
        //2. If We Have More Than One Video We Need To Show All The Controls & Scale The Buttons Slightly
        if videoArray.count > 1 {
            
            controlValues = fullControlValues
            buttonNames = fullButtonNames
            BUTTON_SIZE = 0.35
            
        }else{
            //2a. Assign Basic Controls
            controlValues = miniControlValues
            buttonNames = miniButtonNames
        }
        
        //3. Set The Number Of Buttons
        numberOfButtons = controlValues.count
       
        
        //4. Create A Node To Holder The Video Player
        let videoPlayerHolder = SCNNode()
        
        //5. Create The Plane Geometry With The Passesd Width & Calculate The Height
        let playerHeight = width/1.5
        videoPlayerHolder.geometry = SCNPlane(width: width, height: playerHeight - BUTTON_SIZE)
        
        //6. Create A URL From Our Video Path
        guard let firstVideoPath = videoPaths.first else { return }
        let url = URL(fileURLWithPath: firstVideoPath)
        
        //7. Instanciate The AVPlayer With Our Video URL
        videoPlayer = AVPlayer(url: url)
        
        //8. Initialize The VideoNode With The AVPlayer
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)

        //9. Ensure The Video Is Shown The Right Way Round
        videoPlayerNode.yScale = -1
        
        //10. Initialize The SKScene
        spriteKitScene = SKScene(size: CGSize(width: 1280, height: 960))
        
        //11. Set It's Scale Mode
        spriteKitScene.scaleMode = .aspectFit
        
        //12. Set The VideoPlayerNode Size
        videoPlayerNode.size = spriteKitScene.size
        
        //13. Position The VideoPlayerNode Centrally In The Scene
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        
        //14. Add The VideoPlayerNode To The Scene
        spriteKitScene.addChild(videoPlayerNode)
        
        //15. Set The Planes Geoemtry To Our SpriteKit Scene
        videoPlayerHolder.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
  
        //16. Add The VideoPlayer Holder
        self.addChildNode(videoPlayerHolder)
        
        //17. Play The Video
        videoPlayer.play()
        videoPlayer.volume = 1
        
        //18. Create The Control Buttons
        createControlButtons()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //---------------------
    //MARK: Control Buttons
    //---------------------
    
    /// Create A Row Of Control Buttons
    func createControlButtons(){
        
        //1. Get The Bounding Box Of Our Video Node
        let (min, max) = self.boundingBox
        
        //2. Get The Width Of The Video Node & The Coordinates Of The Left, Right & Bottom Positions Of The Bounding Box
        let leftHandCorner = CGFloat(min.x)
        let bottomOfHolder = CGFloat(min.y)
        let rightHandCorner = CGFloat(max.x)
        let width = rightHandCorner - leftHandCorner
        
        //3. Get The Button Width (Accounting For The Center Point) & The Total Width Of All Buttons
        let buttonWidth = BUTTON_SIZE / 2
        let totalButtonWidth = BUTTON_SIZE * CGFloat(numberOfButtons)
        let buttonsMinusOne = CGFloat(numberOfButtons - 1)
        
        //4. Set The Original Position Of The 1st Node
        var existingXPosition = leftHandCorner + (width - totalButtonWidth - buttonWidth * buttonsMinusOne)/2
        
        //5. Create The Control Buttons
        for index in 0..<numberOfButtons{
            
            let controlButtonNode = SCNNode()
            let controlButtonGeometry = SCNPlane(width: BUTTON_SIZE, height: BUTTON_SIZE)
            controlButtonGeometry.firstMaterial?.diffuse.contents = UIImage(named: buttonNames[index])
            controlButtonNode.geometry = controlButtonGeometry
            controlButtonNode.position = SCNVector3(existingXPosition + buttonWidth, bottomOfHolder - (buttonWidth + 0.05), 0)
            controlButtonNode.name = controlValues[index]
            existingXPosition +=  BUTTON_SIZE + buttonWidth
            self.addChildNode(controlButtonNode)
        }
    }
    
    //-----------------------
    //MARK: PlayBack Controls
    //-----------------------
    
    /// Plays The Current Video Item
    @objc func playVideo(){
        
        self.videoPlayer.seek(to: kCMTimeZero)
        self.videoPlayer.play()
    }
    

    /// Stops The Current Video Item
    func stopVideo(){
        
        self.videoPlayer.seek(to: kCMTimeZero)
        self.videoPlayer.pause()
        
    }
    
    /// Loops The Video PlayBack
    func loopVideo(){
        
        if !loopPlayBack{
            
            loopPlayBack = true
            NotificationCenter.default.addObserver(self, selector: #selector(playVideo),
                                                   name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
        }else{
            
            loopPlayBack = false
     
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
         
        }
        
        changeButtonImage()

    }
    
    /// Mutes The Current Video
    func muteVideo(){
        
        if !videoMuted{
  
            videoMuted = true
            videoPlayer.volume = 0
            
        }else{
            
            videoMuted = false
            videoPlayer.volume = 1
        }
        
        changeButtonImage()
    }
    
    /// Changes The Current AVPlayerItem Video
    ///
    /// - Parameter functionName: String
    func changeVideoItem(_ functionName: String){
        
        switch functionName {
        case "Forwards":
            if currentVideoIndex != videoArray.count-1 { currentVideoIndex += 1 }
        case "Backwards":
            if currentVideoIndex != 0 { currentVideoIndex -= 1 }
        default:
            break
        }
        
        let url = URL(fileURLWithPath: videoArray[currentVideoIndex])
        let newVideoItem = AVPlayerItem(url: url)
        videoPlayer.replaceCurrentItem(with: newVideoItem)
        playVideo()
        
    }
    
    //---------------------
    //MARK: Button Geometry
    //---------------------
    
    /// Changes The Image For The Mute & Loop Buttons
    func changeButtonImage(){
        
        //1. Loop Through All The Child Nodes
        for buttonToChange in self.childNodes{
            
            if buttonToChange.name == "Mute"{
                
                if videoMuted{
                    buttonToChange.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "muteOffButton")
                }else{
                    buttonToChange.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "muteOnButton")
                }
            }
            
            if buttonToChange.name == "Loop"{
                
                if loopPlayBack{
                    buttonToChange.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "loopOffButton")
                }else{
                    buttonToChange.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "loopOnButton")
                }
            }
            
        }
    }
}
