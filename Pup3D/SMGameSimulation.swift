//
//  SMGameSimulation.swift
//  Pup3D
//
//  Created by Martijn Bakker on 14/09/2016.
//  Copyright © 2016 SydneyMae. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import CoreMotion
import SpriteKit

// Collision bit masks
let BitmaskMainCharacter    = 1 << 1
let BitmaskGround           = 1 << 2
let BitmaskCollision        = 1 << 3
let BitmaskCollectable      = 1 << 4
let BitmaskEnemy            = 1 << 5


class SMGameSimulation : SCNScene, SCNSceneRendererDelegate ,SCNPhysicsContactDelegate{
    
    var mainCharacter: SMMainCharacter!
    var mainCharacterNode: SCNNode!
    
    var gameLevel : SMGameLevel!
    var levelNode : SCNNode!
    
    var motionManager: CMMotionManager!    
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
//        init game level class
        gameLevel = SMGameLevel()
        
//        load level
        levelNode = gameLevel.createWorld()
        self.rootNode.addChildNode(levelNode)
        
//        setup collision details of all the level nodes
        self.levelCollision()
     
        self.setupAccelerometer()
     
//        set physicsworld delegate and gravity
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = SCNVector3Make(0, -9.8, 0)
    
//        setup collision and catergory bitmasks for individual nodes
//        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "craneNode")
//        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "trashNode")
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "trafficLightNode")
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "lampPostNode")
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "wallNode")
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "gateNode")
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "benchNode")

    }
    
    class func loadNodeWithName(nodeName:String?, fromSceneNamed: String) -> SCNNode{
        let sceneName = SCNScene(named: fromSceneNamed)
        var node = sceneName?.rootNode
        
        if (nodeName != nil) {
            node = node?.childNode(withName: nodeName!, recursively: true)
        } else {
            node = node?.childNodes[0];
        }
        
        
        return node!
    }
    
    
    
    
    
    
    
    func levelCollision(){
        //        simplified version, in final version enumerate over all the childnodes of "levelgroup" and assign each node it's own convexhull physicsShapeType for a more detailed collision mesh. Enumerate over nodes, place them in an array and "for-loop" the array to add the collisionshape
        let level = levelNode!.childNode(withName: "levelGroup", recursively: true)
        //        set to convexhull when method described above is implemented
        level?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: level!, options: [SCNPhysicsShape.Option.type:SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        level?.physicsBody?.categoryBitMask = BitmaskGround
    }
    
    
    
    func setCategoryBitmask(_ category:Int, andCollisionBitmask collision:Int, forNode node:String){
        let node = levelNode!.childNode(withName: node, recursively: true)
        node?.physicsBody?.collisionBitMask = collision
        node?.physicsBody?.categoryBitMask = category
    }
    
    func renderer(_ aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
        gameLevel.setCharacterAltitude()
        
        //        if _gameState == GameState.inGame{
        //            println("inGame")
        //        }else if _gameState == GameState.paused{
        //            println("paused")
        //        }else if _gameState == GameState.preGame{
        //            println("pregame")
        //        }
        //        if _gameState == GameState.inGame{
        
        //        }
        
    }
    
    
    
        
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA.physicsBody?.categoryBitMask == PhysicsCategory.bone{
            //                _gameSimulation._boneNode.addParticleSystem(_boneParticle)
            score += 1
        }
    }
    //    private func setupCollisionNode(node: SCNNode) {
    //        if let geometry = node.geometry {
    //            // Collision meshes must use a concave shape for intersection correctness.
    //            node.physicsBody = SCNPhysicsBody.staticBody()
    //            node.physicsBody!.categoryBitMask = BitmaskCollision
    //            node.physicsBody!.physicsShape = SCNPhysicsShape(node: node, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron])
    //
    //
    //            // Temporary workaround because concave shape created from geometry instead of node fails
    //            let childNode = SCNNode()
    //            node.addChildNode(childNode)
    //            childNode.hidden = true
    //            childNode.geometry = node.geometry
    //            node.geometry = nil
    //            node.hidden = false
    //
    //            if node.name == "water" {
    //                node.physicsBody!.categoryBitMask = BitmaskWater
    //            }
    //        }
    //
    //        for childNode in node.childNodes {
    //            if childNode.hidden == false {
    //                setupCollisionNode(childNode)
    //            }
    //        }
    //    }

    func setupAccelerometer(){
        //setup motionmanager
        motionManager = CMMotionManager()
        if motionManager.isAccelerometerAvailable{
            motionManager.accelerometerUpdateInterval = 1/60.0
            motionManager.startAccelerometerUpdates(to: OperationQueue()){
                (data, error) in
                
                let threshold = 0.20
                
                //move right
                if data!.acceleration.y < -threshold{
                    
                    let direction = -(CGFloat(data!.acceleration.y) * CGFloat(M_PI*(1/64)))
                    
                    self.gameLevel.mainCharacter.rotateCharacter(direction: direction)
                    
                    self.gameLevel.mainCharacter.running = true
                    
                }
                    //move left
                else if data!.acceleration.y > threshold{
                    
                    let direction = -(CGFloat(data!.acceleration.y) * CGFloat(M_PI*(1/64)))
                    self.gameLevel.mainCharacter.rotateCharacter(direction: direction)
                    
                    self.gameLevel.mainCharacter.running = true
                    
                }
                else{
                    self.gameLevel.mainCharacter.running = false
//                    self.rotate = SCNAction.rotate(by: 0, around: SCNVector3Make(0, 0, 0), duration: 1/60)
                    self.gameLevel.mainCharacter.rotateCharacter(direction: 0)
                }
            }
        }
    }
}
