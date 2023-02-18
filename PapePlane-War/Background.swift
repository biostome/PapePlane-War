//
//  Sky.swift
//  飞机大战
//
//  Created by Hans on 2023/2/13.
//

import Foundation
import UIKit

class SkyBackground: UIView {
    var displayLink: CADisplayLink!
    
    var speed: CGFloat = 1
    
    lazy var sky1: Sky = Sky(frame: .init(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
    
    lazy var sky2: Sky = Sky(frame: .init(x: 0, y: -sky1.frame.height, width: frame.size.width, height: frame.size.height))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(sky1)
        addSubview(sky2)
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .main, forMode: .default)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func update() {
        sky1.frame.origin.y += speed
        sky2.frame.origin.y += speed
        if sky1.frame.origin.y >= frame.size.height {
            sky1.frame.origin.y = -sky1.frame.height
        }
        if sky2.frame.origin.y >= frame.size.height {
            sky2.frame.origin.y = -sky2.frame.height
        }
    }
    
    deinit {
        displayLink.remove(from: .main, forMode: .default)
        displayLink.invalidate()
    }
}

class Sky: UIView {
    
    var images = [UIImageView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let image = UIImage(named: "background") {
            backgroundColor = UIColor(patternImage: image)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

