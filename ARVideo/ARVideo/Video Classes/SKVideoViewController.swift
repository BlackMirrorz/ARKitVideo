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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //1. Check An ARPlaneAnchor Has Been Detected
        guard let _ = anchor as? ARPlaneAnchor else { return }
       
        //2. If We Have Selected Plane Detection & Havent Added the Video Show The Prompt
        if placeOnPlane && !videoPlayerCreated{
            
            planeDetectedPrompt.hideViewAfter(6)
            generateHepticFeedBack()

        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {

            //1. Update The Tracking Status
            self.statusLabel.text = self.augmentedRealitySession.sessionStatus()
            
            //2. If We Have Nothing To Report Then Hide The Status View & Shift The Settings Menu
            if let validSessionText = self.statusLabel.text{
                self.sessionLabelView.isHidden = validSessionText.isEmpty
            }
        
            if self.sessionLabelView.isHidden {
                 self.settingsConstraint.constant = -8
            }else{
                 self.settingsConstraint.constant = -32
            }
        }
    }
}

class SKVideoViewController: UIViewController {
    
    //1. Create A Reference To Our ARSCNView In Our Storyboard Which Displays The Camera Feed
    @IBOutlet weak var augmentedRealityView: ARSCNView!
   
     //2. Create A Reference To Our ARSCNView In Our Storyboard Which Will Display The ARSession Tracking Status
    @IBOutlet weak var sessionLabelView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    //3. Create Our ARWorld Tracking Configuration
    let configuration = ARWorldTrackingConfiguration()
    
    //4. Create Our Session
    let augmentedRealitySession = ARSession()

    //5. Create A Reference Tp The VideoNode
    var videoNode: VideoNodeSK?
    var videoPlayerCreated = false
    
    //6. Variables To Determine If We Are Placing Our VideoNode On Any Detected Planes Or Feature Points
    var placeOnPlane = false
    var placementType: ARHitTestResult.ResultType = .featurePoint
    
    //7. Settings Menu Items
    @IBOutlet var planeDetectedPrompt: UIView!
    @IBOutlet var settingsMenu: UIView!
    @IBOutlet var settingsConstraint: NSLayoutConstraint!
    @IBOutlet var planeDetectionController: UISegmentedControl!
    @IBOutlet var festurePointController: UISegmentedControl!
    var showFeaturePoints = false;
    
    //--------------------
    //MARK: View LifeCycle
    //--------------------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //1. Add A UIPinchGestureRecognizer So We Can Scale Our Video Player
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleVideoPlayer(_:)))
        self.view.addGestureRecognizer(scaleGesture)
        
        //2. Add A Tap Gesture Recogizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(placeVideoNode(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        //3. Hide The PlaneDetection Prompt
        planeDetectedPrompt.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setupARSession()
    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

    //---------------------
    //MARK: Video Placement
    //---------------------
    
    /// Performs An ARHitTest So We Can Place Our VideoNode
    ///
    /// - Parameter gesture: UITapGestureRecognizer
    @objc func placeVideoNode(_ gesture: UITapGestureRecognizer){
        
        //If We Have Created The VideoNode Already Return
        if videoPlayerCreated { return }
        
        //1. Get The Current Location Of The Tap
        let currentTouchLocation = gesture.location(in: self.augmentedRealityView)
        
        //2. Perform An ARHitTest To Search For Any Existing Planes Or Feature Points
        if placeOnPlane { placementType = .existingPlane }
        
        guard  let hitTest = self.augmentedRealityView.hitTest(currentTouchLocation, types: placementType ).first else { return }
        
        //3. Create The Video Player
        if let planeAnchor = hitTest.anchor as? ARPlaneAnchor {
            
            createVideoPlayerFrom(anchor: planeAnchor, position: nil)
            UIApplication.shared.isIdleTimerDisabled = true
            return
            
        }else{
            
            let worldTransform = hitTest.worldTransform.columns.3
            
            createVideoPlayerFrom(anchor: nil,
                                  position: SCNVector3(worldTransform.x, worldTransform.y, -4))
            UIApplication.shared.isIdleTimerDisabled = true
            return
            
        }
        
    }
    
    /// Creates The VideoNodeSK
    ///
    /// - Parameters:
    ///   - anchor: Optional ARPlaneAnchor (Needed If Placing On Horizontal/Vertical Plane)
    ///   - position: Optional SCNVector3 (Needed If Placing On A Feature Point)
    func createVideoPlayerFrom(anchor: ARPlaneAnchor?, position: SCNVector3?){
        
        //1. Load Our Videos From Both The Main Bundle
        guard let videoPathCat = Bundle.main.path(forResource: "blackCat", ofType: "mp4"),
              let videoPathVortex = Bundle.main.path(forResource: "spaceVortex", ofType: "mov") else { return }
       
        let videoPathRemote = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
        
        //2. Initialize The Video Player
        videoNode = VideoNodeSK(videoPaths: [videoPathCat, videoPathVortex, videoPathRemote])
        
        //3. We Are Placing The Video Player On A Plane
        if placeOnPlane {
           
            //a. Check We Have A Valid ARPlaneAnchor & Node
            guard let validAnchor = anchor,
                  let nodeOfAnchor = self.augmentedRealityView.node(for: validAnchor) else { return }
            
            //b. Rotate The Video Player If We Have A Vertical Plane
            videoNode?.eulerAngles.x = -.pi / 2
            
            //c. Add It To Our Hierachy
            nodeOfAnchor.addChildNode(videoNode!)
            
            //d. Scale The Video Player To Match The Initial Size Of The Detected Plane
            videoNode?.scaleVideoPlayerFromAnchor(validAnchor)
            videoPlayerCreated = true
            videoNode?.addVideoDataLabels()
                
            } else{
            
            //4. We Are Placing The VideoNode At The Position Of A Feature Point
            guard let validPosition = position else { return }
            self.augmentedRealityView.scene.rootNode.addChildNode(videoNode!)
            videoNode?.position = SCNVector3(validPosition.x, validPosition.y, validPosition.z)
            videoNode?.addVideoDataLabels()
            videoPlayerCreated = true
        }
     
    }

    //----------------------------------------
    //MARK: Touch Detection For Video Playback
    //----------------------------------------
    
    //Touch Detection For Controlling The Video Playback
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
    @objc func scaleVideoPlayer(_ gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == .changed {
            
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((videoNode!.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((videoNode!.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((videoNode!.scale.z))
            videoNode?.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
            
        }
        if gesture.state == .ended { }
        
    }
    
    //----------------------
    //MARK: Feedback Options
    //----------------------
    
    /// Determines Whether The VideoNode Should Be Placed Using Plane Detection
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func setPlaneDetection(_ controller: UISegmentedControl){
        
        if controller.selectedSegmentIndex == 1{
            placeOnPlane = false
        }else{
            placeOnPlane = true
        }
        
        setupSessionPreferences()
    }
    
    /// Determines Whether The User Should Be Able To See FeaturePoints
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func setFeaturePoints(_ controller: UISegmentedControl){
        
        if controller.selectedSegmentIndex == 1{
            showFeaturePoints = false
        }else{
            showFeaturePoints = true
        }
        
        setupSessionPreferences()
    }
    
    
    /// Runs The ARSessionConfiguration Based On The Preferences Chosen
    func setupSessionPreferences(){
        
        if placeOnPlane{
            configuration.planeDetection = [planeDetection(.Both)]
        }else{
            configuration.planeDetection = [planeDetection(.None)]
        }
        
        if showFeaturePoints{
            
            augmentedRealityView.debugOptions = debug(.FeaturePoints)
        }else{
            
            augmentedRealityView.debugOptions = debug(.None)
        }
        
        //4. Run The Session & Reset The Video Node
        augmentedRealitySession.run(configuration, options: runOptions(.ResetAndRemove))
        videoPlayerCreated = false
        videoNode?.removeFromParentNode()
        videoNode = nil
        
        //5. Disable The Idle Timer
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    //---------------
    //MARK: ARSession
    //---------------
    
    /// Sets Up The ARSession
    func setupARSession(){
        
        //1. Set The AR Session
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealityView.delegate = self
        
        setupSessionPreferences()
        
    }
 
}

