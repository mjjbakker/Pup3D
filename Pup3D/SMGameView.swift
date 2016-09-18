//
//  SMGameView.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 13/12/15.
//  Copyright © 2015 SydneyMae. All rights reserved.
//

import SceneKit
import SpriteKit

class SMGameView: SCNView {
    
    // MARK: 2D Overlay
    
    let overlayNode = SKNode()
    let congratulationsGroupNode = SKNode()
//    private var scoreCountLabel = SKLabelNode(fontNamed: "Myriad Pro")
    var collectedFlowerSprites = [SKSpriteNode]()


    override func awakeFromNib() {
        super.awakeFromNib()
        setup2DOverlay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout2DOverlay()
    }
    
    
    
    func layout2DOverlay() {
        overlayNode.position = CGPoint(x: 0.0, y: bounds.size.height)
        
        congratulationsGroupNode.position = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        
        congratulationsGroupNode.xScale = 1.0
        congratulationsGroupNode.yScale = 1.0
        let currentBbox = congratulationsGroupNode.calculateAccumulatedFrame()
        
        let margin = CGFloat(25.0)
        let maximumAllowedBbox = bounds.insetBy(dx: margin, dy: margin)
        
        let top = currentBbox.maxY - congratulationsGroupNode.position.y
        let bottom = congratulationsGroupNode.position.y - currentBbox.minY
        let maxTopAllowed = maximumAllowedBbox.maxY - congratulationsGroupNode.position.y
        let maxBottomAllowed = congratulationsGroupNode.position.y - maximumAllowedBbox.minY
        
        let left = congratulationsGroupNode.position.x - currentBbox.minX
        let right = currentBbox.maxX - congratulationsGroupNode.position.x
        let maxLeftAllowed = congratulationsGroupNode.position.x - maximumAllowedBbox.minX
        let maxRightAllowed = maximumAllowedBbox.maxX - congratulationsGroupNode.position.x
        
        let topScale = top > maxTopAllowed ? maxTopAllowed / top : 1
        let bottomScale = bottom > maxBottomAllowed ? maxBottomAllowed / bottom : 1
        let leftScale = left > maxLeftAllowed ? maxLeftAllowed / left : 1
        let rightScale = right > maxRightAllowed ? maxRightAllowed / right : 1
        
        let scale = min(topScale, min(bottomScale, min(leftScale, rightScale)))
        
        congratulationsGroupNode.xScale = scale
        congratulationsGroupNode.yScale = scale
    }
    
    func setup2DOverlay() {
        let w = bounds.size.width
        let h = bounds.size.height
        
        // Setup the game overlays using SpriteKit.
        let skScene = SKScene(size: CGSize(width: w, height: h))
        skScene.scaleMode = .resizeFill
        
        skScene.addChild(overlayNode)
        overlayNode.position = CGPoint(x: 0.0, y: h)
        
//        The Clock icon.
        let clockNode = SKSpriteNode(imageNamed: "timer")
        overlayNode.addChild(clockNode)
        clockNode.position = CGPoint(x: 30, y: -30)

//        The ClockCount label
        let clockCountNode = SKLabelNode(fontNamed: "Myriad Pro")
        clockCountNode.text = "00:00"
        overlayNode.addChild(clockCountNode)
        clockCountNode.position = CGPoint (x: 100, y: -40)
        
//        The Score icon
        let scoreNode = SKSpriteNode(imageNamed: "bone")
        overlayNode.addChild(scoreNode)
        scoreNode.position = CGPoint(x: w + 20, y: -30)
        
//        The ScoreCount Label
        let scoreCountNode = SKLabelNode(fontNamed: "Myriad Pro")
        scoreCountNode.text = "0"
        overlayNode.addChild(scoreCountNode)
        scoreCountNode.position = CGPoint(x: w-60, y: -40)
  
//        Assign the SpriteKit overlay to the SceneKit view.
        overlaySKScene = skScene
        skScene.isUserInteractionEnabled = false
    }



}
