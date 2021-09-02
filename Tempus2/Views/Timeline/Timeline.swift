//
//  Timeline.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

public struct Timeline {
    public var width: CGFloat {
        didSet {
            if (width < Timeline.minWidth) {
                width = Timeline.minWidth
            }
        }
    }
    
    public var (frontColor, backColor) = (
        Timeline.defaultFrontColor,
        Timeline.defaultBackColor
    )
    
    public var leftMargin: CGFloat = Timeline.defaultLeftMargin
    
    internal var (start, middle, end) = (
        CGPoint(x: 0, y: 0),
        CGPoint(x: 0, y: 0),
        CGPoint(x: 0, y: 0)
    )
    
    // MARK: - Init
    
    public init(width: CGFloat, frontColor: UIColor, backColor: UIColor) {
        self.width = width
        self.frontColor = frontColor
        self.backColor = backColor
        self.leftMargin -= width / 2
    }
    
    public init(frontColor: UIColor, backColor: UIColor) {
        self.init(
            width: Timeline.defaultWidth,
            frontColor: frontColor,
            backColor: backColor
        )
    }
    
    public init() {
        self.init(
            width: Timeline.defaultWidth,
            frontColor: UIColor.black,
            backColor: UIColor.black
        )
    }
    
    public func draw(view: UIView) {
        draw(
            view: view,
            from: start,
            to: middle,
            color: frontColor
        )
        draw(
            view: view,
            from: middle,
            to: end,
            color: backColor
        )
    }
}

// MARK: - Fileprivate Methods
fileprivate extension Timeline {
    func draw(view: UIView, from: CGPoint, to: CGPoint, color: UIColor) {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineCap = .round

        view.layer.addSublayer(shapeLayer)
    }
}

extension Timeline {
    static let defaultWidth: CGFloat = 20
    static let minWidth: CGFloat = 0
    
    static let defaultFrontColor = UIColor.black
    static let defaultBackColor = UIColor.black
    
    static let defaultLeftMargin: CGFloat = 100
}
