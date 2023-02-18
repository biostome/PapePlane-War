//
//  BulletView.swift
//  飞机大战
//
//  Created by Hans on 2023/2/12.
//

import Foundation
import UIKit

protocol Bullet: UIView {
    var speed: CGFloat { get set }
    var damage: CGFloat { get set }
    func fly()
}

class PlayerBulletView: UIView, Bullet {
    
    var displayLink: CADisplayLink?
    var speed: CGFloat = 10
    var damage: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageView = UIImageView(image: UIImage(named: "bullet1"))
        addSubview(imageView)
        imageView.frame = .init(x: (frame.width - 5) * 0.5, y: (frame.height - 11) * 0.5, width: 5, height: 11)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fly(){
        displayLink = CADisplayLink(target: self, selector: #selector(updatePosition))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc func updatePosition(){
        self.frame.origin.y -= speed
        if self.frame.origin.y <= 0 {
            self.displayLink?.invalidate()
            self.removeFromSuperview()
        }
        
        // 如果击中敌机
        for view in self.superview?.subviews ?? [] {
            if let enemyView = view as? EnemyPlane, !enemyView.isDown, self.frame.intersects(enemyView.frame) {
                enemyView.takeDamage(damage: -20)
                if enemyView.health <= 0 {
                    enemyView.isDown = true
                    enemyView.explode()
                    break
                }
                
                self.displayLink?.invalidate()
                self.removeFromSuperview()
                break
            }
        }
    }
    
    deinit {
        self.displayLink?.invalidate()
    }

}

class EnemyBulletView: UIView, Bullet {
    
    var damage: CGFloat = -30
    
    var displayLink: CADisplayLink?
    
    var speed: CGFloat = CGFloat.random(in: 0.5...1)
    
    var bulletImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bullet2"))
        imageView.frame = CGRect(x: 0, y: 0, width: 5, height: 11)
        return imageView
    }()
    
    var halfWidth: CGFloat
    var halfHeight: CGFloat
    
    init(center: CGPoint) {
        let frame = CGRect(x: center.x - 2.5, y: center.y - 5.5, width: 5, height: 11)
        halfWidth = frame.width / 2
        halfHeight = frame.height / 2
        super.init(frame: frame)
        
        addSubview(bulletImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fly() {
        displayLink = CADisplayLink(target: self, selector: #selector(updatePosition))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc func updatePosition() {
        let dy = 10 * speed
        let y = self.frame.origin.y + dy
        self.frame.origin.y = y
        if y >= UIScreen.main.bounds.height {
            displayLink?.invalidate()
            removeFromSuperview()
        }
        
        for view in self.superview?.subviews ?? [] {
            if let plane = view as? PlayerPlane, !plane.isDown, frame.intersects(plane.frame) {
                plane.takeDamage(damage: damage)
                if plane.health <= 0 {
                    plane.isDown = true
                    plane.explode()
                    break
                }
                
                displayLink?.invalidate()
                removeFromSuperview()
                break
            }
        }
    }
    
    func hide() {
        bulletImageView.isHidden = true
    }
    
    func show() {
        bulletImageView.isHidden = false
    }
}
