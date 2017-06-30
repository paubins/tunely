//
//  UIColor+.swift
//  Stutter
//
//  Created by Patrick Aubin on 6/27/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        
        let redPart: CGFloat = CGFloat(red) / 255
        let greenPart: CGFloat = CGFloat(green) / 255
        let bluePart: CGFloat = CGFloat(blue) / 255
        
        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
    }
}
