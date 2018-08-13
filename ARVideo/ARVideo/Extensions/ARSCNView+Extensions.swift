//
//  ARSCNView+Extensions.swift
//  ARVideo
//
//  Created by Josh Robbins on 18/05/2018.
//  Copyright © 2018 BlackMirror. All rights reserved.
//

import Foundation
import ARKit

extension ARSCNView{
    
    
    /// Adds A Ripple Effect To An ARSCNView
    func rippleView(){
        
        let animation = CATransition()
        animation.duration = 1.75
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = convertToCATransitionType("rippleEffect")
        self.layer.add(animation, forKey: nil)
       
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
	return CATransitionType(rawValue: input)
}
