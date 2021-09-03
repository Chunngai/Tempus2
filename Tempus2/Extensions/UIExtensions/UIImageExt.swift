//
//  UIImageExt.swift
//  Tempus2
//
//  Created by Sola on 2021/8/31.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func set(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        
        color.setFill()
        
        let bounds = CGRect(
            x: 0,
            y: 0,
            width: self.size.width,
            height: self.size.height
        )
        UIRectFill(bounds)
        self.draw(
            in: bounds,
            blendMode: CGBlendMode.destinationIn,
            alpha: 1.0
        )
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return coloredImage!
    }
}
