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
    
    // MARK: - Color Conversions
    
    func convertTo(color: UIColor) -> UIImage {
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

extension UIImage {
    
    // MARK: - Resizing
    
    func resize(widthRatio: CGFloat, heightRatio: CGFloat) -> UIImage {
        let newSize = widthRatio > heightRatio
            ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resize(to targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        return resize(widthRatio: widthRatio, heightRatio: heightRatio)
    }
    
    func scale(to ratio: CGFloat) -> UIImage {
        return resize(widthRatio: ratio, heightRatio: ratio)
    }
}
