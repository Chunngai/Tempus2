//
//  TimelinePoint.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

public struct TimelinePoint {
    public var diameter: CGFloat {
        didSet {
            if (diameter < TimelinePoint.minDiameter) {
                diameter = TimelinePoint.minDiameter
            } else if (diameter > TimelinePoint.maxDiameter) {
                diameter = TimelinePoint.maxDiameter
            }
        }
    }
    
    public var lineWidth: CGFloat {
        didSet {
            if (lineWidth < TimelinePoint.minLineWidth) {
                lineWidth = TimelinePoint.minLineWidth
            } else if (lineWidth > TimelinePoint.maxLineWidth) {
                lineWidth = TimelinePoint.maxLineWidth
            }
        }
    }
    
    public var color = TimelinePoint.defaultColor
    
    public var isFilled = false
    
    internal var position = CGPoint(x: 0, y: 0)
    
    public init(diameter: CGFloat, lineWidth: CGFloat, color: UIColor, filled: Bool) {
        self.diameter = diameter
        self.lineWidth = lineWidth
        self.color = color
        self.isFilled = filled
    }
    
    public init(diameter: CGFloat, color: UIColor, filled: Bool) {
        self.init(
            diameter: diameter,
            lineWidth: TimelinePoint.defaultLineWidth,
            color: color,
            filled: filled
        )
    }
    
    public init(color: UIColor, filled: Bool) {
        self.init(
            diameter: TimelinePoint.defaultDiameter, lineWidth:
            TimelinePoint.defaultLineWidth,
            color: color, filled:
            filled
        )
    }
    
    public init() {
        self.init(
            diameter: TimelinePoint.defaultDiameter, lineWidth:
            TimelinePoint.defaultLineWidth,
            color: UIColor.black,
            filled: false
        )
    }
    
    public func draw(view: UIView) {
        let path = UIBezierPath(
            ovalIn: CGRect(
                x: position.x - diameter / 2,
                y: position.y - diameter / 2,
                width: diameter,
                height: diameter
            )
        )

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = isFilled ?
            color.cgColor :
            UIColor.white.cgColor
        shapeLayer.lineWidth = lineWidth

        view.layer.addSublayer(shapeLayer)
    }
}

extension TimelinePoint {
    static let defaultDiameter: CGFloat = 10
    static let minDiameter: CGFloat = 0
    static let maxDiameter: CGFloat = 100
    
    static let defaultLineWidth: CGFloat = 1
    static let minLineWidth: CGFloat = 0
    static let maxLineWidth: CGFloat = 20
    
    static let defaultColor = UIColor.black
}
