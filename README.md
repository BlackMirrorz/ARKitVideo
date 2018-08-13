
# ARKitVideo

This project is a basic example of Video PlayBack in `ARKit` using a combination of `SKScene`, `SKVideoNode`, and `AVPlayer`.

All the code is fully commented so the apps functionality should be clear to everyone.

**Branches:**

The Master Branch was originally compiled in XCode10 Beta using Swift 4.

An updated Branch called 'Swift4.2' contains the project built in XCode 10.5 Beta and uses Swift 4.2.

**Core Functionality:**

The `VideoNodeSK` Class takes an array of `[String]` as the paths to the videos, and has controls for:

 - Play,
 - Stop.
 - Loop,
 - Mute,
 - Play Next,
 - Play Last.

The playback controls are managed using an `SCNHitTest` in the `touchesBegan` method of the `SKVideoViewController`:

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

Currently the `VideoNodeSK` can play videos from the main Bundle, or from remote URL's.

The `VideoNodeSK` will also display the name of the current video, as well it's current playback time.

The `VideoNodeSK` can be placed on either `horizontal` or `vertical` planes, as well as at the location of a detected `featurePoint`.

Setting up the `VideoNodeSK` is as a simple as adding the following to your viewDidLoad:

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //1. Load Our Videos From Both The Main Bundle
        guard let videoPathCat = Bundle.main.path(forResource: "blackCat", ofType: "mp4"),
        let videoPathVortex = Bundle.main.path(forResource: "spaceVortex", ofType: "mov") else { return }
        let videoPathRemote = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"

        //2. Initialize The Video Node With Our Videos
        let nodeToAdd = VideoNodeSK(videoPaths: [videoPathCat, videoPathVortex, videoPathRemote])

        //3. Add It To The Scene Hierachy & Set It Back 4m
        augmentedRealityView.scene.rootNode.addChildNode(nodeToAdd)
        nodeToAdd.position = SCNVector3(0, 0, -4)
        
    }

The `VideoNodeSK` also supports zooming in and out using a `UIPinchGestureRecognizer` added to the `SKVideoViewController` .
