//
//  Text.swift
//  Setup
//
//  Created by Josh Robbins on 24/02/2018.
//  Copyright © 2018 BlackMirror. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class Text: SCNNode{
    
    enum TextAlignment{
        
        case Left
        case Right
        case Center
    }

    var textGeometry: SCNText!
    
    //--------------------
    //MARK: Initialization
    //--------------------
    
    /// Creates An SCNText Geometry
    ///
    /// - Parameters:
    ///   - text: String (The Text To Be Displayed)
    ///   - depth: Optional CGFloat (Defaults To 1)
    ///   - font: UIFont
    ///   - textSize: Optional CGFloat (Defaults To 1)
    ///   - colour: UIColor
    init(text: String, depth: CGFloat = 1, font: String = "Helvatica", textSize: CGFloat = 1, colour: UIColor) {
        
        super.init()
        
        //1. Create The Text Geometry With String & Depth Parameters
        textGeometry = SCNText(string: text , extrusionDepth: depth)
    
        //2. Set The Font With Our Set Font & Size
        textGeometry.font = UIFont(name: font, size: textSize)
        
        //3. Set The Flatness To Zero (This Makes The Text Look Smoother)
        textGeometry.flatness = 0
        
        //4. Set The Colour Of The Text
        textGeometry.firstMaterial?.diffuse.contents = colour
        
        //5. Set The Text's Material
        self.geometry = textGeometry
        
        //6. Scale The Text So We Can Actually See It!
        self.scale = SCNVector3(0.01, 0.01 , 0.01)
    
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //-----------------------
    //MARK: Pivot Positioning
    //-----------------------
    
    /// Sets The Pivot Of The TextNode
    ///
    /// - Parameter alignment: TextAlignment
    func setTextAlignment(_ alignment: TextAlignment){
       
        //1. Get The Bounding Box Of The TextNode
        let min = self.boundingBox.min
        let max = self.boundingBox.max
        
        switch alignment {
        
        case .Left:
            self.pivot = SCNMatrix4MakeTranslation(
                min.x,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
        case .Right:
            self.pivot = SCNMatrix4MakeTranslation(
                max.x,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
        case .Center:
            self.pivot = SCNMatrix4MakeTranslation(
                min.x + (max.x - min.x)/2,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
        }
        
    }

}
