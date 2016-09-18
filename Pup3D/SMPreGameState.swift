//
//  SMMainMenu.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 25/06/15.
//  Copyright (c) 2015 SydneyMae. All rights reserved.
//

import Foundation
import SpriteKit

class SMPreGameState : SKNode {
    var _gameLogo:SKSpriteNode!
    var _menuBackground:SKLabelNode!
    
    var _preGameText : SKLabelNode!
    
    init(frameSize: CGSize){
        super.init()
        self.position = CGPoint(x: frameSize.width * 0.5, y: frameSize.height * 0.15)
        self.isUserInteractionEnabled = true
        
//        self._gameLogo = SKSpriteNode(imageNamed: "art.scnassets/artwork/gameLogo.png")
        _preGameText = SMIngameScene.labelWithText("tap to start", textSize: 24)
        _preGameText.horizontalAlignmentMode = .center
        _preGameText.position = CGPoint(x: frameSize.width/2, y: frameSize.height/5)
        
        
//        var size = self._gameLogo.size
//        var factor = frameSize.width / size.width
//        
//        size.width *= factor
//        size.height *= factor
//        
//        self._gameLogo.size = size
//        
//        self._gameLogo.anchorPoint = CGPointMake(1, 0)
//        self._gameLogo.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
//        self.addChild(_gameLogo)
        self.addChild(_preGameText)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchUpAtPoint(point:CGPoint){
        self.isHidden = true
//        SMGameViewController.sharedInstance.setGameState(GameState.inGame)
    }
}


