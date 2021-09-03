//
//  Separator.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class Separator: UIView {
    
    private let color: UIColor = .lightGray
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func updateViews() {
        backgroundColor = color
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
