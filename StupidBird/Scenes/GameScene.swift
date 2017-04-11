//
//  GameScene.swift
//  StupidBird
//
//  Created by SangNP on 4/3/17.
//  Copyright © 2017 SangNP. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Private enum
    private enum State {
        case tutorial, running, paused, gameOver
    }
    
    // MARK: - Private class constants
    private let cloudController = CloudController()
    private let hills = Hills()
    private let ground = Ground()
    private let tutorial = Tutorial()
    private let floppy = Floppy()
    private let logController = LogController()
    private let scoreLabel = ScoreLabel()
    private let gameNode = SKNode()
    private let interfaceNode = SKNode()
    private let pauseButton = PauseButton()
    
    // MARK: - Private class variables
    private var lastUpdateTime:TimeInterval = 0.0
    private var state:State = .tutorial
    private var previousState:State = .tutorial
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        
        // Register notifications for "Pause"
        NotificationCenter.default.addObserver(self, selector: #selector(paused), name: NSNotification.Name(rawValue: "Pause"), object: nil)
        
        // Register notifications for "Resume"
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGame), name: NSNotification.Name(rawValue: "Resume"), object: nil)
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        self.backgroundColor = Colors.colorFrom(rgb: Colors.sky)
        
        self.addChild(gameNode)
        
        gameNode.addChild(scoreLabel)
        gameNode.addChild(cloudController)
        gameNode.addChild(hills)
        gameNode.addChild(logController)
        gameNode.addChild(ground)
        gameNode.addChild(tutorial)
        gameNode.addChild(floppy)
        
        self.addChild(interfaceNode)
        interfaceNode.addChild(pauseButton)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = Contact.scene
        self.physicsBody?.collisionBitMask = 0x0
        self.physicsBody?.contactTestBitMask = 0x0
    }
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        switch state {
        case .tutorial:
            cloudController.update(delta: delta)
            
        case .running:
            cloudController.update(delta: delta)
            floppy.update()
            logController.update(delta: delta)
            ground.update(delta: delta)
            hills.update(delta: delta)
            
        case .paused:
            return
            
        case .gameOver:
            return
        }
    }
    
    // MARK: - Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        let touchLocation = touch.location(in: self)
        
        if pauseButton.contains(touchLocation) {
            pausePressed()
        }
        
        if state == .tutorial {
            if tutorial.contains(touchLocation) {
                tutorial.tapepd()
                running()
            }
        } else if state == .running {
            floppy.fly()
        }
    }
    
    // MARK: - Contact
    func didBegin(_ contact: SKPhysicsContact) {
        if state != .running {
            return
        } else {
            // Which body is not Floppy?
            let other = contact.bodyA.categoryBitMask == Contact.floppy ? contact.bodyB : contact.bodyA
            
            if other.categoryBitMask == Contact.scene {
                // Player hit the ground or the ceiling
                floppy.crashed()
                shake()
                flash()
                gameOver()
            }
            
            if other.categoryBitMask == Contact.log {
                // Player hit a log
                floppy.smacked()
                shake()
                flash()
                gameOver()
            }
            
            if other.categoryBitMask == Contact.score {
                floppy.updateScore()
                scoreLabel.updateScore(score: floppy.getScore())
            }
            
        }
    }
    
    // MARK: - State
    private func running() {
        state = .running
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -10)
    }
    
    func paused() {
        previousState = state
        state = .paused
        
        gameNode.speed = 0.0
        
        self.physicsWorld.gravity = CGVector.zero
        self.physicsWorld.speed = 0.0
    }
    
    func gameOver() {
        state = .gameOver
        
        floppy.gameOver()
        
        pauseButton.run(SKAction.scale(to: 0.0, duration: 0.25), completion: {
            [weak self] in
            self?.pauseButton.removeFromParent()
        })
        
        self.run(SKAction.wait(forDuration: 2.0), completion: {
            [weak self] in
            self?.loadScene()
        })
    }
    
    func resume() {
        state = previousState
        
        gameNode.speed = 1.0
        
        if previousState == .running  || previousState == .gameOver {
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        } else {
            self.physicsWorld.gravity = CGVector.zero
        }
        
        self.physicsWorld.speed = 1.0
    }
    
    func resumeGame() {
        // Run a timer that resumes the game after 1 second
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(resume), userInfo: nil, repeats: false)
    }
    
    private func pausePressed() {
        // Flip the texture shown on the button
        pauseButton.tapped()
        
        if pauseButton.getPauseState() {
            // Set the state to paused
            paused()
            
            // Pause the gameNode
            gameNode.isPaused = true
        } else {
            // Resume the previous state
            resume()
            
            // Resume the gameNode
            gameNode.isPaused = false
        }
    }
    
    // MARK: - Scene Animations
    private func shake() {
        gameNode.run(SKAction.shake(amount: CGPoint(x: 16, y: 16), duration: 0.5))
    }
    
    private func flash() {
        let colorFlash = SKAction.run {
            [weak self] in
            self?.backgroundColor = Colors.colorFrom(rgb: Colors.flash)
            
            self?.run(SKAction.wait(forDuration: 0.5), completion: {
                [weak self] in
                self?.backgroundColor = Colors.colorFrom(rgb: Colors.sky)
            })
        }
        
        self.run(colorFlash)
    }
    
    // MARK: - Load Scene
    private func loadScene() {
        let scene = GameOverScene(size: kViewSize, score: floppy.getScore())
        let transition = SKTransition.fade(with: SKColor.black, duration: 0.5)
        
        self.view?.presentScene(scene, transition: transition)
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
