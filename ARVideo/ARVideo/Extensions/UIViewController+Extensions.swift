//
//  UIViewController+Extensions.swift
//  ARVideo
//
//  Created by Josh Robbins on 16/05/2018.
//  Copyright © 2018 BlackMirror. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    /// Generates Heptic Feeback
    func generateHepticFeedBack(){
        
        //If We Are Running An IOS Greater Than 10, Implement Heptic Feedback
        if #available(iOS 10.0, *) {
            
            DispatchQueue.main.async {
              
                let hepticFeedback = UIImpactFeedbackGenerator(style: .heavy)
                hepticFeedback.prepare()
                hepticFeedback.impactOccurred()
                
            }
        }
    }
}

extension UIView{
    
    /// Hides A UIView After A Specified Duration
    ///
    /// - Parameter delay: Double
    func hideViewAfter(_ delay: Double){
        
        DispatchQueue.main.async {
          
            self.alpha = 1
            
            UIView.animate(withDuration: delay, animations: {
                self.alpha = 0
            })
        }
    }
}
