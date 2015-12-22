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
    
    private let overlayNode = SKNode()
    private let congratulationsGroupNode = SKNode()
    private let collectedPearlCountLabel = SKLabelNode(fontNamed: "Chalkduster")
    private var collectedFlowerSprites = [SKSpriteNode]()


    override func awakeFromNib() {
        super.awakeFromNib()
        setup2DOverlay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout2DOverlay()
    }
    
    private func layout2DOverlay() {
        overlayNode.position = CGPointMake(0.0, bounds.size.height)
        
        congratulationsGroupNode.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5)
        
        congratulationsGroupNode.xScale = 1.0
        congratulationsGroupNode.yScale = 1.0
        let currentBbox = congratulationsGroupNode.calculateAccumulatedFrame()
        
        let margin = CGFloat(25.0)
        let maximumAllowedBbox = CGRectInset(bounds, margin, margin)
        
        let top = CGRectGetMaxY(currentBbox) - congratulationsGroupNode.position.y
        let bottom = congratulationsGroupNode.position.y - CGRectGetMinY(currentBbox)
        let maxTopAllowed = CGRectGetMaxY(maximumAllowedBbox) - congratulationsGroupNode.position.y
        let maxBottomAllowed = congratulationsGroupNode.position.y - CGRectGetMinY(maximumAllowedBbox)
        
        let left = congratulationsGroupNode.position.x - CGRectGetMinX(currentBbox)
        let right = CGRectGetMaxX(currentBbox) - congratulationsGroupNode.position.x
        let maxLeftAllowed = congratulationsGroupNode.position.x - CGRectGetMinX(maximumAllowedBbox)
        let maxRightAllowed = CGRectGetMaxX(maximumAllowedBbox) - congratulationsGroupNode.position.x
        
        let topScale = top > maxTopAllowed ? maxTopAllowed / top : 1
        let bottomScale = bottom > maxBottomAllowed ? maxBottomAllowed / bottom : 1
        let leftScale = left > maxLeftAllowed ? maxLeftAllowed / left : 1
        let rightScale = right > maxRightAllowed ? maxRightAllowed / right : 1
        
        let scale = min(topScale, min(bottomScale, min(leftScale, rightScale)))
        
        congratulationsGroupNode.xScale = scale
        congratulationsGroupNode.yScale = scale
    }
    
    private func setup2DOverlay() {
        let w = bounds.size.width
        let h = bounds.size.height
        
        // Setup the game overlays using SpriteKit.
        let skScene = SKScene(size: CGSize(width: w, height: h))
        skScene.scaleMode = .ResizeFill
        
        skScene.addChild(overlayNode)
        overlayNode.position = CGPoint(x: 0.0, y: h)
        
        // The Max icon.
        let timerNode = SKSpriteNode(imageNamed: "timer")
        overlayNode.addChild(timerNode)
        timerNode.position = CGPoint(x: 50, y: -50)
//            , position: CGPoint(x: 50, y:-50), scale: 0.5))
        
        // Assign the SpriteKit overlay to the SceneKit view.
        overlaySKScene = skScene
        skScene.userInteractionEnabled = false
    }



}
