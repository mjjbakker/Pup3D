//
//  SMInGameScene.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 10/06/15.
//  Copyright (c) 2015 SydneyMae. All rights reserved.
//

import Foundation
import SpriteKit

protocol gameStateDelegate{
    func setGameState(_ gameState : GameState) 
}

protocol animationDelegate{
    func dogJump()
}

let fontName = "MyriadPro-Bold"

class SMIngameScene : SKScene{
    var _timeLabelValue: SKSpriteNode!
    var _timeValue: SKLabelNode!
    var _scoreLabelValue: SKSpriteNode!
    var _scoreValue: SKLabelNode!
    
    var _menuNode : SMPreGameState!
    var _pauseNode : SMPauseGameState!
    
    var _gameState : GameState!
    
    var _gameStateDelegate: gameStateDelegate?
    
    var _animationDelegate: animationDelegate?
    
    var timer = Timer() //make a timer variable, but do do anything yet
    let timeInterval:TimeInterval = 0.05
    let timerEnd:TimeInterval = 10.0
    var timeCount:TimeInterval = 120.0
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
        
        
        self.name = "skOverlay"
        let height = size.height
        let width = size.width
        self._timeLabelValue = SMIngameScene.labelWithImage(image: "timer", size: CGSize(width: 60, height: 60), point: CGPoint(x: 30, y: height-30))
        _timeLabelValue.zPosition = 120
        self.addChild(_timeLabelValue)
        
        let time = SKLabelNode(fontNamed: fontName)
        time.text = timeString(timeCount)
        time.fontSize = 24
        time.fontColor = SKColor(cgColor: UIColor.orange.cgColor)
        _timeValue = time
        _timeValue.position = CGPoint(x: 130, y: height - 38)
        self.addChild(_timeValue)
        
        self._scoreLabelValue = SMIngameScene.labelWithImage(image: "bone", size: CGSize(width: 60, height: 60), point: CGPoint(x: width-40, y: height-30))
        _scoreLabelValue.zPosition = 10
        self.addChild(_scoreLabelValue)
        
        self._scoreValue = SMIngameScene.labelWithText("0", textSize: 24)
        self._scoreValue.position = CGPoint(x: width - 90, y: height - 38)
        self.addChild(_scoreValue)
        
        self.hideInGameUI(true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func labelWithText(_ text: String, textSize: CGFloat) -> SKLabelNode{
        let myLabel = SKLabelNode(fontNamed: fontName)
        
        myLabel.text = text
        myLabel.fontSize = textSize
        myLabel.fontColor = SKColor(cgColor: UIColor.orange.cgColor)
        
        return myLabel
    
    }
    
    class func labelWithImage(image: String, size: CGSize, point: CGPoint) -> SKSpriteNode{
        let myImage = SKSpriteNode(imageNamed: image)
        myImage.size = size
        myImage.position = point
        myImage.name = image
        
        return myImage
    }
    
    func setGameState(_ gameState: GameState){
        if _menuNode != nil{
            _menuNode.removeFromParent()
        }
        _gameState = gameState
        if gameState == GameState.preGame{
            _menuNode = SMPreGameState(frameSize: self.frame.size)
            self.addChild(_menuNode)
        }else if gameState == GameState.inGame{
            self.startTimer()
            _menuNode.isHidden = true
            self.hideInGameUI(false)
            if _pauseNode != nil{
                _pauseNode.isHidden = true
            }
        }else if gameState == GameState.paused{
            _pauseNode = SMPauseGameState(frameSize: self.frame.size)
            self.addChild(_pauseNode)
            self.hideInGameUI(true)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        _scoreValue.text = String(score)
    }
    
    func hideInGameUI(_ bool : Bool){
        _timeLabelValue.isHidden = bool
        _timeValue.isHidden = bool
        _scoreLabelValue.isHidden = bool
        _scoreValue.isHidden = bool
    }
    
    func touchUpAtPoint(_ location : CGPoint){
        if _gameState == GameState.preGame{
            _menuNode.touchUpAtPoint(point: location)
            self.hideInGameUI(false)
            
//            SMGameViewController.sharedInstance.setGameState(GameState.inGame)
            
        }else if _gameState == GameState.inGame{
            let touchedNode = self.scene!.atPoint(location) as SKNode
//            println("gameState inGame")
//            println("touchedNode = \( touchedNode)")
            if touchedNode == _timeLabelValue{
//                println("pause tapped")
                _gameStateDelegate!.setGameState(GameState.paused)
            }else{
                _animationDelegate!.dogJump()
            }
            
            
        }
        
    }
    
    func startTimer() {
        if !timer.isValid{ //prevent more than one timer on the thread
            
            
            _timeValue.text = timeString(timeCount)
            timer = Timer.scheduledTimer(timeInterval: timeInterval,
                target: self,
                selector: #selector(SMIngameScene.timerDidEnd(_:)),
                userInfo: nil,
                repeats: true) //repeating timer in the second iteration
        }
    }
    
    func timeString(_ time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let secondFraction = (Int((time - Double(seconds)) * 10.0)) % 10
        
        
        return String(format:"%02i:%02i.%i",minutes,seconds,secondFraction)
    }
    
    func timerDidEnd(_ timer:Timer){
        //timerLabel.text = timer.userInfo as? String
        
        
        //timer that counts down
        timeCount = timeCount - timeInterval
        if timeCount <= 0 {  //test for target time reached.
            _timeValue.text = "game over!!"
            timer.invalidate()
        } else { //update the time on the clock if not reached
            _timeValue.text = timeString(timeCount)
        }
    }
}
