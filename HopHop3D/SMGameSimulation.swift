//
//  SMGameSimulation.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 24/06/15.
//  Copyright (c) 2015 SydneyMae. All rights reserved.
//

import Foundation
import SceneKit

class SMGameSimulation {
    
    
    var mainCharacter:SCNNode!
    var spotLightNode: SCNNode!
    var rotate: SCNMatrix4!
    
    var rotation: SCNVector4!
    
    var moveAcc: SCNAction!
    var rotateAcc: SCNAction!
    
    var inRunAnimation: Bool! = false
    
    var rig : SMAnimatedCharacter!
    
    func makeMainCharacterNode() -> SCNNode {
//        func makeMainCharacterNode(scene:SCNScene){
    
        let characterScene = SCNScene(named: "art.scnassets/mainCharacter.scn")!
        let characterNode = characterScene.rootNode.childNodeWithName("mainCharacterGroup", recursively: true)
        mainCharacter = SCNNode()
        mainCharacter = characterNode
                
        // Collisions are handled by the physics engine. The character is approximated by
        // a capsule that is configured to collide with collectables, enemies and walls
        
        let (min, max) = mainCharacter.boundingBox
        let collisionCapsuleRadius = CGFloat(max.x - min.x) * 0.4
        let collisionCapsuleHeight = CGFloat(max.y - min.y)

        let characterCollisionNode = SCNNode()
        characterCollisionNode.name = "collider"
        characterCollisionNode.position = SCNVector3(0, collisionCapsuleHeight * 0.51, 0) // a bit too high so that the capsule does not hit the floor
        characterCollisionNode.physicsBody = SCNPhysicsBody(type: .Kinematic, shape:SCNPhysicsShape(geometry: SCNCapsule(capRadius: collisionCapsuleRadius, height: collisionCapsuleHeight), options:nil))
        characterCollisionNode.physicsBody!.contactTestBitMask = BitmaskSuperCollectable | BitmaskCollectable | BitmaskCollision | BitmaskEnemy
        characterCollisionNode.physicsBody?.angularVelocityFactor = SCNVector3Make(0, 0, 0)
        
        mainCharacter.addChildNode(characterCollisionNode)
        mainCharacter.castsShadow = true
        mainCharacter.name = "mainCharacter"
        
        rig = SMAnimatedCharacter(characterNode: mainCharacter)
        
        setupRunAnimation()
        
        return mainCharacter
    }
    
    func keyForAnimationType(animType : DogAnimation ) -> String{
        switch (animType){
        case .idle:
            return "idle-1"
        case .run:
            return "run-1"
        case .turn:
            return "turn-1"
        case .jumpStart:
            return "jumpStart-1"
        case .jumpEnd:
            return "jumpEnd-1"
        case .jump:
            return "jump-1"
            
        }
    }
        
    func setupRunAnimation(){
        let runAnimation : CAAnimation? = rig.loadAndCacheAnimation("art.scnassets/run", name: keyForAnimationType(DogAnimation.run), key: keyForAnimationType(DogAnimation.run))
        
        if runAnimation != nil{
            runAnimation?.repeatCount = FLT_MAX
            runAnimation?.fadeInDuration = 0.15
            runAnimation?.fadeOutDuration = 0.15
        }
    }
        
    func setInRunAnimation(runAnimState: Bool){
//        print("setInRunAnim called")
        if inRunAnimation == runAnimState{
            return
        }
        inRunAnimation = runAnimState
        
        if (inRunAnimation == true){
            let runKey = keyForAnimationType(DogAnimation.run)
//            let idleKey = keyForAnimationType(DogAnimation.idle)
            let runAnim = rig.cachedAnimationForKey(runKey)
//            mainSkeleton.removeAnimationForKey(idleKey, fadeOutDuration: 0.15)
            rig.mainSkeleton.addAnimation(runAnim, forKey: runKey)
        }
        else{
            let runKey = keyForAnimationType(DogAnimation.run)
            rig.mainSkeleton.removeAnimationForKey(runKey, fadeOutDuration: 0.15)
            inRunAnimation = false
        }
    }
}
