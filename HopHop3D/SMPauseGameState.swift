//
//  SMPauseMenu.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 27/06/15.
//  Copyright (c) 2015 SydneyMae. All rights reserved.
//

import Foundation
import SpriteKit

class SMPauseGameState : SKNode{
    
    var _scoreLabel : SKLabelNode!
    var _timeLabel : SKLabelNode!
    var _scoreValueLabel : SKLabelNode!
    var _timeValueLabel : SKLabelNode!
    var _pauseLabel : SKLabelNode!
    
    var _tapLabel : SKLabelNode!
    
    init(frameSize : CGSize){
        super.init()
        _pauseLabel = SMIngameScene.labelWithText("game paused", textSize: 36)
        _pauseLabel.position = CGPointMake((frameSize.width/2) - 20, (frameSize.height/2) + 80)
        
        _scoreLabel = SMIngameScene.labelWithText("Score", textSize: 24)
        _scoreLabel.position = CGPointMake((frameSize.width/2) - 20, (frameSize.height/2))
        
        _timeLabel = SMIngameScene.labelWithText("Time", textSize: 24)
        _timeLabel.position = CGPointMake((frameSize.width/2) - 20, (frameSize.height/2) - 40)
        
        _tapLabel = SMIngameScene.labelWithText("tap to continue", textSize: 18)
        _tapLabel.position = CGPointMake((frameSize.width/2) - 20, (frameSize.height/2) - 120)
        
        self.addChild(_pauseLabel)
        self.addChild(_scoreLabel)
        self.addChild(_timeLabel)
        self.addChild(_tapLabel)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchUpAtPoint(point point:CGPoint){
//        println("touch up paused called")
        self.hidden = true
//        SMGameViewController.sharedInstance.setGameState(GameState.inGame)
    }
    
    
}
