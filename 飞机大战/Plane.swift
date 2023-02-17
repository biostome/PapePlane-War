//
//  PlaneView.swift
//  飞机大战
//
//  Created by Hans on 2023/2/12.
//

import Foundation
import UIKit

protocol PlaneDelegate {
    func destory(plane: UIView)
    func fire(plane: UIView, bullet:UIView, bulletCount: Int)
}

/// 飞行能力
protocol Flyable {
    func move(to position: CGPoint)
}

/// 攻击能力
protocol Attackable {
    func fire()
}

/// 爆炸能力
protocol Explodable{
    /// 爆炸
    func explode()
}

/// 抵抗
protocol Resistant {
    /// 抵抗
    func takeDamage(damage: Double)
}

/// 显示
protocol Visible{
    func display()
}

protocol Profile {
    var name: String {set get}
    
    var health: Double {set get}
}

protocol Planeable: Flyable, Attackable, Explodable,Resistant, Visible, Profile {}

class PlayerPlane: UIView, Planeable {
    var name: String

    var isDown: Bool
    
    var health: Double
    
    var shootTimer: Timer?
    
    var healthBar: HealthBar?
    
    var delegate: PlaneDelegate?
    
    private let maxBulletCount: Int
    private var bulletCount: Int
    private var autoReplenishBullets: Bool
    
    init(frame: CGRect,
         name: String,
         health: Double,
         isDown: Bool = false,
         healthBar: HealthBar?,
         bulletCount: Int = 100,
         autoReplenishBullets: Bool = false) {
        self.name = name
        self.health = health
        self.isDown = isDown
        self.healthBar = healthBar
        self.maxBulletCount = bulletCount
        self.bulletCount = bulletCount
        self.autoReplenishBullets = autoReplenishBullets
        super.init(frame: frame)
        
        if let image = UIImage(named: "me1") {
            let imageView = UIImageView(image: image)
            addSubview(imageView)
            imageView.frame.origin = .zero
            imageView.frame.size = .init(width: frame.width, height: frame.height)
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = false
        }
        
        if let bar = self.healthBar {
            addSubview(bar)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.autoReplenishBullets {
            shootTimer = Timer.scheduledTimer(timeInterval: 0.2,
                                              target: self,
                                              selector: #selector(fireWithAutoReplenish),
                                              userInfo: nil,
                                              repeats: true)
        } else {
            shootTimer = Timer.scheduledTimer(timeInterval: 0.2,
                                              target: self,
                                              selector: #selector(fire),
                                              userInfo: nil,
                                              repeats: true)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: superview)
        let previous = touch.previousLocation(in: superview)
        let deltaX = location.x - previous.x
        let deltaY = location.y - previous.y
        let newX = center.x + deltaX
        let newY = center.y + deltaY
        
        
        
        if newX < bounds.width / 2 || newX > UIScreen.main.bounds.width - (bounds.width / 2) {
            return
        }
        if newY > UIScreen.main.bounds.height - (bounds.width / 2) - (superview?.safeAreaInsets.bottom ?? 0){
            return
        }
        
        move(to: .init(x: newX, y: newY))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        shootTimer?.invalidate()
        shootTimer = nil
    }
    
    func move(to position: CGPoint) {
        self.center = position
    }
    
    // 重载 fire 函数
    @objc func fireWithAutoReplenish() {
        // 如果没有子弹，则不发射
        guard bulletCount > 0 else { return }
        
        let bullet = PlayerBulletView(frame: .init(x: center.x - 2.5, y: frame.minY, width: 5, height: 11))
        superview?.addSubview(bullet)
        bullet.fly()
        
        bulletCount -= 1
        
        // 如果当前子弹数小于最大子弹数-1，则补充子弹
        if bulletCount < maxBulletCount - 1 {
            replenishBullets()
        }
        self.delegate?.fire(plane: self, bullet: bullet, bulletCount: bulletCount)
    }
    
    @objc func fire() {
        // 如果没有子弹，则不发射
        guard bulletCount > 0 else { return }
        
        let bullet = PlayerBulletView(frame: .init(x: center.x - 2.5, y: frame.minY, width: 5, height: 11))
        superview?.addSubview(bullet)
        bullet.fly()
        
        bulletCount -= 1
        self.delegate?.fire(plane: self, bullet: bullet, bulletCount: bulletCount)
    }
    
    // 新增补充子弹函数
    func replenishBullets() {
        bulletCount += 1
    }
    
    
    func explode() {
        let imageNames = ["me_destroy_1","me_destroy_2","me_destroy_3","me_destroy_4"]
        var images = [UIImage]()
        for name in imageNames {
            if let image = UIImage(named: name) {
                images.append(image)
            }
        }
        let imageView = UIImageView(frame: bounds)
        imageView.animationImages = images
        imageView.animationDuration = 0.5
        imageView.animationRepeatCount = 1
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.startAnimating()
        
        
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.alpha = 0
        } completion: { finish in
            self.delegate?.destory(plane: self)
//            self.removeFromSuperview()
            self.shootTimer?.invalidate()
            self.shootTimer = nil
        }

        print("GAME OVER")
    }
    
    func takeDamage(damage: Double) {
        health += damage
        healthBar?.health = health
        healthBar?.setNeedsDisplay()
        UIView.animate(withDuration: 0.1, delay: 0) {
            self.alpha = 0.3
        } completion: { finish in
            self.alpha = 1
        }
    }
    
    func display() {
        isHidden = false
    }
    
    func hidden(){
        isHidden = true
    }
    
    func reset(health: CGFloat, isDown: Bool = false){
        self.health = health
        self.isDown = isDown
        
    }
    
    deinit {
        self.shootTimer?.invalidate()
        self.shootTimer = nil
    }
    
}


class EnemyPlane: UIView, Planeable {
    var name: String
    
    var playerView: UIView?
    
    var displayLink: CADisplayLink?
    
    var isDown: Bool
    
    var health: Double
    
    var timer: Timer?
    
    var speed: CGFloat = CGFloat.random(in: 0.5...1)
    
    var delegate: PlaneDelegate?
    
    var fireTimerInterval: TimeInterval
    
    var healthBar: HealthBar?
    
    init(frame: CGRect,
         fireTimerInterval: TimeInterval,
         name: String,
         health: Double,
         isDown: Bool = false,
         healthBar: HealthBar?) {
        self.fireTimerInterval = fireTimerInterval
        self.name = name
        self.health = health
        self.isDown = isDown
        self.healthBar = healthBar
        super.init(frame: frame)
        
        if let image = UIImage(named: "enemy1") {
            let imageView = UIImageView(image: image)
            addSubview(imageView)
            imageView.frame = self.bounds
            imageView.contentMode = .scaleAspectFit
        }
        
        timer = Timer.scheduledTimer(timeInterval: fireTimerInterval,
                                     target: self,
                                     selector: #selector(fire),
                                     userInfo: nil,
                                     repeats: true)
        
        
        if let bar = self.healthBar {
            addSubview(bar)
        }
        clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fly(){
        displayLink = CADisplayLink(target: self, selector: #selector(updatePosition))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc func updatePosition(){
        self.frame.origin.y += 1 * speed
        if self.frame.origin.y >= UIScreen.main.bounds.height {
            displayLink?.invalidate()
            self.removeFromSuperview()
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    @objc func fire(){
        let bullet = EnemyBulletView(center: self.center)
        superview?.addSubview(bullet)
        bullet.fly()
    }
    
    @objc func explode(){
        let imageNames = ["enemy1_down1","enemy1_down2","enemy1_down3","enemy1_down4"]
        var images = [UIImage]()
        for name in imageNames {
            if let image = UIImage(named: name) {
                images.append(image)
            }
        }
        let imageView = UIImageView(frame: bounds)
        imageView.animationImages = images
        imageView.animationDuration = 0.3
        imageView.animationRepeatCount = 1
        addSubview(imageView)
        imageView.startAnimating()
        
        
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.alpha = 0
        } completion: { finish in
            self.delegate?.destory(plane: self)
            self.displayLink?.invalidate()
            self.removeFromSuperview()
            self.timer?.invalidate()
            self.timer = nil
        }

    }

    @objc func takeDamage(damage: Double){
        health += damage
        healthBar?.health = health
        healthBar?.setNeedsDisplay()
        UIView.animate(withDuration: 0.1, delay: 0) {
            self.alpha = 0.3
        } completion: { finish in
            self.alpha = 1
        }
    }
    
    func move(to position: CGPoint) {
        self.frame.origin = position
    }
    
    func display() {
        self.isHidden = false
    }
    
    deinit {
        self.displayLink?.invalidate()
    }
}
