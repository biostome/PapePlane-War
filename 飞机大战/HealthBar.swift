//
//  HealthBar.swift
//  飞机大战
//
//  Created by Hans on 2023/2/14.
//

import Foundation
import UIKit

class HealthBar: UIView {
    
    var health: CGFloat = 100
    
    init(frame: CGRect, health: CGFloat) {
        super.init(frame: frame)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let width = rect.width * health / 100
        let color = UIColor.green
        let bar = UIBezierPath(rect: .init(x: 0, y: 0, width: width, height: rect.height))
        color.setFill()
        bar.fill()
    }
}
