//
//  SKVideoViewController.swift
//  ARVideo
//
//  Created by Josh Robbins on 18/03/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//


import UIKit
import ARKit

//-----------------------
//MARK: ARSCNViewDelegate
//-----------------------

extension SKVideoViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            
            //1. Update The Tracking Status
            self.statusLabel.text = self.augmentedRealitySession.sessionStatus()
            
        }
    }
}

class SKVideoViewController: UIViewController {
    
    //1. Create A Reference To Our ARSCNView In Our Storyboard Which Displays The Camera Feed
    @IBOutlet weak var augmentedRealityView: ARSCNView!
   
     //2. Create A Reference To Our ARSCNView In Our Storyboard Which Will Display The ARSession Tracking Status
    @IBOutlet weak var statusLabel: UILabel!
    
    //3. Create Our ARWorld Tracking Configuration
    let configuration = ARWorldTrackingConfiguration()
    
    //4. Create Our Session
    let augmentedRealitySession = ARSession()

    //5. Create A Reference Tp The VideoNode
    var videoNode: VideoNodeSK!
    
    //--------------------
    //MARK: View LifeCycle
    //--------------------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //1. Load Our Videos From Both The Main Bundle
        guard let videoPathCat = Bundle.main.path(forResource: "blackCat", ofType: "mp4"),
        let videoPathVortex = Bundle.main.path(forResource: "spaceVortex", ofType: "mov") else { return }
        let videoPathRemote = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"

        //2. Initialize The Video Node With Our Videos
        videoNode = VideoNodeSK(videoPaths: [videoPathCat, videoPathVortex, videoPathRemote])

        //3. Add It To The Scene Hierachy & Set It Back 4m
        augmentedRealityView.scene.rootNode.addChildNode(videoNode)
        videoNode.position = SCNVector3(0, 0, -4)
        
        //4. Add A UIPinchGestureRecognizer So We Can Scale Our Video Player
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleVideo(_:)))
        self.view.addGestureRecognizer(scaleGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setupARSession()
    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

    //----------------------------------------
    //MARK: Touch Detection For Video Playback
    //----------------------------------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //1. Get The Current Touch Location
        guard let touchLocation = touches.first?.location(in: self.augmentedRealityView),
            
            //2. Perform An SCNHitTest To See If We Have Touch A Control Button
            let hitTest = self.augmentedRealityView.hitTest(touchLocation, options: nil).first,
            
            //3. Check The Parent Node Is Our VideoNodeSK
            let videoNode = hitTest.node.parent as? VideoNodeSK,
            
            //4. Check We Have Hit A Control Button
            let functionName = hitTest.node.name else { return }
        
        
        //5. Perform The Video Playback Function
        switch functionName {
        case "Play":
            videoNode.playVideo()
        case "Stop":
            videoNode.stopVideo()
        case "Loop":
            videoNode.loopVideo()
        case "Mute":
            videoNode.muteVideo()
        case "Forwards", "Backwards":
            videoNode.changeVideoItem(functionName)
        default:
            return
        }
        
    }
    
    //-------------------
    //MARK: Video Scaling
    //-------------------
    
    /// Scales The VideoNodeSK
    ///
    /// - Parameter gesture: UIPinchGestureRecognizer
    @objc func scaleVideo(_ gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == .changed {
            
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((videoNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((videoNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((videoNode.scale.z))
            videoNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
            
        }
        if gesture.state == .ended { }
        
    }
    
    //---------------
    //MARK: ARSession
    //---------------
    
    /// Sets Up The ARSession
    func setupARSession(){
        
        //1. Set The AR Session
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealityView.delegate = self
        
        //2. Conifgure The Type Of Plane Detection
        configuration.planeDetection = [planeDetection(.Vertical)]
        
        //3. Configure The Debug Options
        augmentedRealityView.debugOptions = debug(.None)
        
        //4. Run The Session
        augmentedRealitySession.run(configuration, options: runOptions(.ResetAndRemove))
        
 
    }
 
}

