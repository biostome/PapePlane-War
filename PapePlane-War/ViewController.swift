//
//  ViewController.swift
//  飞机大战
//
//  Created by Hans on 2023/2/12.
//

import UIKit

class ViewController: UIViewController {
    
    var score: Int = 0
    lazy var scoreLabel = UILabel(frame: .init(x: 20, y: 20, width: 100, height: 80))
    
    var bulletCount: Int = 0
    lazy var bulletCountLabel = UILabel(frame: .init(x: 140, y: 20, width: 140, height: 80))
    var timer: Timer?
    
    
    
    
    
    // 开始游戏按钮
    lazy var startButton: UIButton = {
        let button = UIButton(frame: .init(x: view.center.x - 100, y: view.center.y - 50, width: 200, height: 100))
        button.setImage(.init(named: "resume_nor"), for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        return button
    }()
    
    // 重新开始按钮
    lazy var restartButton: UIButton = {
        let button = UIButton(frame: .init(x: view.center.x - 100, y: view.center.y - 50, width: 200, height: 100))
        button.setImage(.init(named: "again"), for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sky = SkyBackground(frame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.insertSubview(sky, at: 0)
        view.addSubview(startButton) // 显示开始游戏按钮
        
        scoreLabel.text = "Score:\(score)"
        scoreLabel.textAlignment = .center
        scoreLabel.font = .systemFont(ofSize: 24)
        view.addSubview(scoreLabel)
        
        
        bulletCountLabel.text = "Score:\(score)"
        bulletCountLabel.textAlignment = .center
        bulletCountLabel.font = .systemFont(ofSize: 24)
        view.addSubview(bulletCountLabel)
        
        
    }
    
    /// 开始游戏
    @objc func startGame() {
        startButton.removeFromSuperview() // 隐藏开始游戏按钮
        restartButton.removeFromSuperview() // 隐藏重新开始按钮
        
        let player = PlayerPlane(frame: .init(x: view.center.x - 52/2, y: view.bounds.height - 90, width: 71, height: 63),
                                 name: "F1",
                                 health: 100,
                                 healthBar: HealthBar(frame: .init(x: 0, y: -10, width: 63, height: 5),
                                                      health: 100),
                                 bulletCount: 100,
                                 autoReplenishBullets: false)
        player.isHidden = false
        player.reset(health: 100)
        player.delegate = self
        bulletCount = 100
        bulletCountLabel.text = "Bullets:\(bulletCount)"
        view.addSubview(player)
        // 两秒生成一架敌机
        startScheduledTimerGenerateEnemy()
    }
    
    @objc func restartGame() {
        // 重置得分
        score = 0
        scoreLabel.text = "Score: \(score)"
        
        // 隐藏重新开始按钮
        restartButton.removeFromSuperview()
        
        // 重新设置玩家飞机的位置和可见性
        let player = PlayerPlane(frame: .init(x: view.center.x - 52/2, y: view.bounds.height - 90, width: 71, height: 63),
                                 name: "F1",
                                 health: 100,
                                 healthBar: HealthBar(frame: .init(x: 0, y: -10, width: 63, height: 5),
                                                      health: 100),
                                 bulletCount: 100,
                                 autoReplenishBullets: false)
        bulletCount = 100
        bulletCountLabel.text = "Bullets:\(bulletCount)"
        player.isHidden = false
        player.reset(health: 100)
        player.delegate = self
        view.addSubview(player)
        startScheduledTimerGenerateEnemy()
    }
    
    func startScheduledTimerGenerateEnemy(){
        // 两秒生成一架敌机
        self.view.subviews.forEach { plane in
            if plane is EnemyPlane {
                plane.removeFromSuperview()
            }
        }
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(generateEnemy), userInfo: nil, repeats: true)
    }
    
    /// 生成敌机
    @objc func generateEnemy(){
        let planeFrame = CGRect(x: CGFloat.random(in: 0...view.frame.width), y: 0, width: 40, height: 40)
        let fireInterval = TimeInterval.random(in: 1...5)
        let planeName = "Enemy"
        let health = 100.0
        let healthBar = HealthBar(frame: .init(x: 0, y: -10, width: 40, height: 5) , health: health)
        
        let plane = EnemyPlane(frame: planeFrame,
                               fireTimerInterval: fireInterval,
                               name: planeName,
                               health: health,
                               healthBar: healthBar)
        
        plane.fly()
        plane.delegate = self
        view.addSubview(plane)
    }
    
    /// 更新分数
    func updateScore() {
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
}

extension ViewController: PlaneDelegate {
    func destory(plane: UIView) {
        if plane is EnemyPlane {
            score += 1
            scoreLabel.text = "Score:\(score)"
        }
        if plane is PlayerPlane {
            plane.isHidden = true
            restartButton.isHidden = false
            view.addSubview(restartButton) // 显示重新开始按钮
        }
    }
    
    func fire(plane: UIView, bullet: UIView, bulletCount: Int) {
        if plane is PlayerPlane {
            print(bulletCount)
            self.bulletCount = bulletCount
            self.bulletCountLabel.text = "Bullets:\(self.bulletCount)"
        }
        
    }
    
}
