//
//  SMGameLevel.swift
//  Pup3D
//
//  Created by Martijn Bakker on 15/09/2016.
//  Copyright © 2016 SydneyMae. All rights reserved.
//

import Foundation
import SceneKit

class SMGameLevel {
    
    var gameLevelNode : SCNNode!
    var mainCharacter : SMMainCharacter!
    var levelScene : SCNScene!
    
    
    
    var run : SCNAction!
    var rotate : SCNAction!
    var move : SCNMatrix4!
    var convert : SCNMatrix4!
    var dogSpeed:Float = 2.5
    
    var mainCharacterSpeed : Float = 0.0
    
    var cameraNode: SCNNode!
    var spotLightNode: SCNNode!
    
    func createWorld() -> SCNNode{
        self.gameLevelNode = SCNNode()
        
        levelScene = SCNScene(named: "art.scnassets/world/world.scn")
        let levelNode = levelScene.rootNode
//            .childNode(withName: "levelGroup", recursively: true)
        self.gameLevelNode.addChildNode(levelNode)
        self.addMainCharacter()
        
        let startPosition = levelNode.childNode(withName: "startingPoint", recursively: true)
       
        mainCharacter.transform = startPosition!.transform
        self.addBeachBall()
        
//        setup camera
        ////        set active camera
        //    gameView.pointOfView = cameraNode
        self.setupCamera()
        mainCharacter!.addChildNode(cameraNode)
        
//         setup lights
        setupLights()
        
//        setup spotlight
        let targetSpotlightConstraint = SCNLookAtConstraint(target: mainCharacter)
        targetSpotlightConstraint.isGimbalLockEnabled = true
        spotLightNode.constraints = [targetSpotlightConstraint]
        self.mainCharacter.addChildNode(spotLightNode)
        


        
        
        return self.gameLevelNode
    }
    
    func addMainCharacter(){
        let rootCharacter = SMGameSimulation.loadNodeWithName(nodeName: nil, fromSceneNamed: "art.scnassets/characters/mainCharacter/mainCharacterIdle.dae")
        

        
        mainCharacter = SMMainCharacter(characterNode: rootCharacter)
//        create empty child node of main character for camera to follow
        let emptyNode = SCNNode()
        mainCharacter!.addChildNode(emptyNode)
        emptyNode.position = SCNVector3Make(-1, 0.5, 0)
        self.gameLevelNode.addChildNode(mainCharacter)
        
        
    }
    
    func setupCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.name = "camera"
        cameraNode.camera!.zFar = 500
        cameraNode.camera?.xFov = 75
        
        cameraNode.position = SCNVector3Make(-50,30 ,0)
        cameraNode.eulerAngles = SCNVector3Make(Float(-M_PI_4)/3, Float(-M_PI_2), 0)
    }
    
    func setupLights(){
        
        spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light?.type = SCNLight.LightType.spot
        spotLightNode.light?.color = UIColor(white: 0.7, alpha: 1.0)
        spotLightNode.position = SCNVector3Make(4, 10, 4)
        spotLightNode.rotation = SCNVector4Make(1, 0, 0, Float(-M_PI/2.8))
        spotLightNode.light?.spotInnerAngle = 0
        spotLightNode.light?.spotOuterAngle = 30
        spotLightNode.light?.shadowColor = UIColor.black
        spotLightNode.light?.zFar = 100
        spotLightNode.light?.zNear = 1
        spotLightNode.name = "spotLight"
        spotLightNode.light!.castsShadow = true
        
        //        gameView.scene!.rootNode.castsShadow = true;
    }
    
    func addBeachBall(){
        let ball = SCNNode()
        ball.position = SCNVector3Make(15, 20, 160);
        ball.geometry = SCNSphere(radius: 0.4)
        ball.geometry!.firstMaterial!.locksAmbientWithDiffuse = true;
        ball.geometry!.firstMaterial!.diffuse.contents = "art.scnassets/textures/ballDiffuse.jpg";
        ball.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 1, 1);
        ball.geometry!.firstMaterial!.diffuse.wrapS = SCNWrapMode.mirror
        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry:ball.geometry!, options: [SCNPhysicsShape.Option.type:SCNPhysicsShape.ShapeType.boundingBox]))
        ball.physicsBody!.restitution = 0.9;
        ball.physicsBody?.collisionBitMask = BitmaskMainCharacter | BitmaskGround
        ball.physicsBody?.categoryBitMask = BitmaskCollision
        //        ball.physicsBody?.collisionBitMask = BitmaskMainCharacter
        gameLevelNode!.addChildNode(ball)
    }
    
    func setCharacterAltitude(){
        mainCharacter.controlCharacterAltitude(levelScene, forCharacter: mainCharacter)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //           print("renderer called")
        //        if (loadingScreenActive == true){
        //            println("remove loadingscreen called")
        //        spinner?.stopAnimating()
        //        spinner?.removeFromSuperview()
        //        blackBackground?.removeFromSuperview()
        //            loadingScreenActive = false
        //        }
        //        mainCharacter.runAction(run)
        
        move = SCNMatrix4MakeTranslation(mainCharacterSpeed, 0, 0)
        convert = mainCharacter.convertTransform(move, to: nil)
        
        
        
        run = SCNAction.move(to: SCNVector3Make(convert.m41, convert.m42, convert.m43), duration: 1/60)
        mainCharacter.runAction(run)
        mainCharacter.runAction(rotate)
        
        
        if (mainCharacter.running == true){
            mainCharacter.setInRunAnimation(true)
        }else{
            mainCharacter.setInRunAnimation(false)
        }
    }
    
    
}
