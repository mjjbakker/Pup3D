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
    func setGameState(gameState : GameState) 
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
    
    var timer = NSTimer() //make a timer variable, but do do anything yet
    let timeInterval:NSTimeInterval = 0.05
    let timerEnd:NSTimeInterval = 10.0
    var timeCount:NSTimeInterval = 120.0
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
        
        
        self.name = "skOverlay"
        let height = size.height
        let width = size.width
        self._timeLabelValue = SMIngameScene.labelWithImage(image: "timer", size: CGSizeMake(60, 60), point: CGPointMake(30, height-30))
        _timeLabelValue.zPosition = 120
        self.addChild(_timeLabelValue)
        
        let time = SKLabelNode(fontNamed: fontName)
        time.text = timeString(timeCount)
        time.fontSize = 24
        time.fontColor = SKColor(CGColor: UIColor.orangeColor().CGColor)
        _timeValue = time
        _timeValue.position = CGPointMake(130, height - 38)
        self.addChild(_timeValue)
        
        self._scoreLabelValue = SMIngameScene.labelWithImage(image: "bone", size: CGSizeMake(60, 60), point: CGPointMake(width-40, height-30))
        _scoreLabelValue.zPosition = 10
        self.addChild(_scoreLabelValue)
        
        self._scoreValue = SMIngameScene.labelWithText("0", textSize: 24)
        self._scoreValue.position = CGPointMake(width - 90, height - 38)
        self.addChild(_scoreValue)
        
        self.hideInGameUI(true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func labelWithText(text: String, textSize: CGFloat) -> SKLabelNode{
        let myLabel = SKLabelNode(fontNamed: fontName)
        
        myLabel.text = text
        myLabel.fontSize = textSize
        myLabel.fontColor = SKColor(CGColor: UIColor.orangeColor().CGColor)
        
        return myLabel
    
    }
    
    class func labelWithImage(image image: String, size: CGSize, point: CGPoint) -> SKSpriteNode{
        let myImage = SKSpriteNode(imageNamed: image)
        myImage.size = size
        myImage.position = point
        myImage.name = image
        
        return myImage
    }
    
    func setGameState(gameState: GameState){
        if _menuNode != nil{
            _menuNode.removeFromParent()
        }
        _gameState = gameState
        if gameState == GameState.preGame{
            _menuNode = SMPreGameState(frameSize: self.frame.size)
            self.addChild(_menuNode)
        }else if gameState == GameState.inGame{
            self.startTimer()
            _menuNode.hidden = true
            self.hideInGameUI(false)
            if _pauseNode != nil{
                _pauseNode.hidden = true
            }
        }else if gameState == GameState.paused{
            _pauseNode = SMPauseGameState(frameSize: self.frame.size)
            self.addChild(_pauseNode)
            self.hideInGameUI(true)
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        _scoreValue.text = String(score)
    }
    
    func hideInGameUI(bool : Bool){
        _timeLabelValue.hidden = bool
        _timeValue.hidden = bool
        _scoreLabelValue.hidden = bool
        _scoreValue.hidden = bool
    }
    
    func touchUpAtPoint(location : CGPoint){
        if _gameState == GameState.preGame{
            _menuNode.touchUpAtPoint(point: location)
            self.hideInGameUI(false)
            
//            SMGameViewController.sharedInstance.setGameState(GameState.inGame)
            
        }else if _gameState == GameState.inGame{
            let touchedNode = self.scene!.nodeAtPoint(location) as SKNode
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
        if !timer.valid{ //prevent more than one timer on the thread
            
            
            _timeValue.text = timeString(timeCount)
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
                target: self,
                selector: "timerDidEnd:",
                userInfo: nil,
                repeats: true) //repeating timer in the second iteration
        }
    }
    
    func timeString(time:NSTimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let secondFraction = (Int((time - Double(seconds)) * 10.0)) % 10
        
        
        return String(format:"%02i:%02i.%i",minutes,seconds,secondFraction)
    }
    
    func timerDidEnd(timer:NSTimer){
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
