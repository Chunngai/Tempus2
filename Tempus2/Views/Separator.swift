//
//  Separator.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class Separator: UIView {
    
    private var color: UIColor!
    
    // MARK: - Init
    
    init(frame: CGRect = .zero, color: UIColor = .lightGray) {
        super.init(frame: frame)
        
        self.color = color
        backgroundColor = self.color
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let path = CGMutablePath()
        path.move(to: CGPoint(
            x: 0,
            y: 0
        ))
        path.addLine(to: CGPoint(
            x: frame.maxX,
            y: frame.minY
        ))
        
        context.addPath(path)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
    }
}
