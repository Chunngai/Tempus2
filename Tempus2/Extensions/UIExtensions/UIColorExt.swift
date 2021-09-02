//
//  UIColorExt.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func intRGB2UIColor(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor {
        return UIColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: alpha
        )
    }
    
    static func hexRGB2UIColor (_ hex:String) -> UIColor {
        var hexString: String = hex.trimmingWhitespacesAndNewlines().uppercased()
        
        if (hexString.hasPrefix("#")) {
            hexString.remove(at: hexString.startIndex)
        }
        
        if ((hexString.count) != 6) {
            return UIColor.black
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        return UIColor.intRGB2UIColor(
            red: Int((rgbValue & 0xFF0000) >> 16),
            green: Int((rgbValue & 0x00FF00) >> 8),
            blue: Int(rgbValue & 0x0000FF),
            alpha: 1
        )
    }
}

extension UIColor {
    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var rgba: RGBA? {
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        return getRed(&r, green: &g, blue: &b, alpha: &a) ? (r,g,b,a) : nil
    }
    
    static func mix(_ colorA: UIColor, with colorB: UIColor) -> UIColor {
        let mixedR = (colorA.rgba!.red + colorB.rgba!.red) / 2
        let mixedG = (colorA.rgba!.green + colorB.rgba!.green) / 2
        let mixedB = (colorA.rgba!.blue + colorB.rgba!.blue) / 2
        let mixedA = (colorA.rgba!.alpha + colorB.rgba!.alpha) / 2
        return UIColor(
            red: mixedR,
            green: mixedG,
            blue: mixedB,
            alpha: mixedA
        )
    }
}
