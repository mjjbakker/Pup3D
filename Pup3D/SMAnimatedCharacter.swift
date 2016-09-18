//
//  SMAnimatedCharacter.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 17/06/15.
//  Copyright (c) 2015 SydneyMae. All rights reserved.
//

import Foundation
import SceneKit

var _animationsDictionary : [String:CAAnimation]!


class SMAnimatedCharacter : SCNNode, CAAnimationDelegate{
    
    var mainSkeleton:SCNNode!
    
    
    init(characterNode: SCNNode){
        super.init()
        
        self.addChildNode(characterNode)
//        characterNode.position = SCNVector3Make(0, 0, 0)
        self.enumerateChildNodes(){
            (node, stop) -> Void in
            if node.skinner != nil{
                self.mainSkeleton = node.skinner!.skeleton
            }
        }
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cachedAnimationForKey(_ key: String) -> CAAnimation{
        return _animationsDictionary[key]!
    }
    
//    func loadAnimationNamed(_ animationName:String) -> CAAnimation{
//        let animation = CAAnimation.animationWithSceneNamed("art.scnassets/mainCharacterRun.scn")
//        
//        animation!.fadeInDuration = 0.3
//        animation!.fadeOutDuration = 0.3
//        return animation!
//        
//    }
    
//    func loadAnimationNamed(animationName:String, sceneName:String) -> CAAnimation{
//
//        let url = Bundle.main.url(forResource: sceneName, withExtension: "scn")
//        let sceneSource = SCNSceneSource(url: url!, options: nil)
//        let animation = sceneSource?.entryWithIdentifier(animationName, withClass: CAAnimation.self)
//
//        animation!.fadeInDuration = 0.3
//        animation!.fadeOutDuration = 0.3
//        
//        return animation!
//    }
    
        func loadAnimationNamed(animationName:String, sceneName:String) -> CAAnimation{
    //        var sceneName = sceneName
    //        sceneName.append(".dae")
//            var animArray = [CAAnimation]()
//            let scene = SCNScene(named: sceneName)
    //        let sceneSource = SCNSceneSource(url: url!, options: nil)
    //        let animation = scene?.rootNode.animation(forKey: animationName)
            let animation = CAAnimation.animationWithSceneNamed(sceneName)
    //        let animation = scene?.rootNode.childNode(withName: "mainCharacterGroup", recursively: true)?.animation(forKey: animationName)
    
            animation!.fadeInDuration = 0.3
            animation!.fadeOutDuration = 0.3
                
    
            
    
    //        animation!.repeatCount = Float.infinity
            
            return animation!
        }
    
//    func loadAnimationNamed(animationName:String, sceneName:String) -> [CAAnimation]{
////        var sceneName = sceneName
////        sceneName.append(".dae")
//        var animArray = [CAAnimation]()
//        let scene = SCNScene(named: sceneName)
////        let sceneSource = SCNSceneSource(url: url!, options: nil)
////        let animation = scene?.rootNode.animation(forKey: animationName)
////        let animation = CAAnimation.animationWithSceneNamed(sceneName)
////        let animation = scene?.rootNode.childNode(withName: "mainCharacterGroup", recursively: true)?.animation(forKey: animationName)
//        
//        for animationKey: String in (scene?.rootNode.animationKeys)!{
//            print(animationKey)
//            let animation = scene?.rootNode.animation(forKey: animationKey)
//            animation!.fadeInDuration = 0.3
//            animation!.fadeOutDuration = 0.3
//            animation!.delegate = self
//            animArray.append(animation!)
//            
//        }
//        
////        animation!.repeatCount = Float.infinity
//        
//        return animArray
//    }

    
    func loadAndCacheAnimation( _ daeFile: String, name: String, key:String) ->CAAnimation{
        if _animationsDictionary == nil{
            _animationsDictionary = [:]
        }
//        let ext = ".scn"
//        daeFile.appendContentsOf(ext)
        
        let anim : CAAnimation? = loadAnimationNamed(animationName: name, sceneName: daeFile)
        print(anim)
        if (anim != nil) {
            _animationsDictionary[key] = anim
            anim!.delegate = self
        }
        
        return anim!
    }
    
    func chainAnimation2(_ firstKey:String, secondKey:String, fadeTime:CGFloat){
        let firstAnimation : CAAnimation? = cachedAnimationForKey(firstKey)
        let secondAnimation : CAAnimation? = cachedAnimationForKey(secondKey)
        
        if (firstAnimation == nil || secondAnimation == nil){
            return
        }
        
        let chainEventBlock: SCNAnimationEventBlock = { animation, animatedObject, playingBackwards in
            self.mainSkeleton.addAnimation(secondAnimation!, forKey: secondKey)
        }
            
        if firstAnimation?.animationEvents == nil || firstAnimation?.animationEvents!.count == 0 {
            firstAnimation?.animationEvents = [SCNAnimationEvent(keyTime: fadeTime, block: chainEventBlock)]
        }
        
    }
        
    func chainAnimation1(_ firstKey:String, secondKey:String){
        chainAnimation2(firstKey, secondKey: secondKey, fadeTime: 0.85)
    }
    
    func update(_ deltaTime:TimeInterval){
        
    }
    
    func controlCharacterAltitude(_ scene:SCNScene, forCharacter:SCNNode){
        var groundAltitude:Float = 0
        let position = forCharacter.position
        var p0 = position
        var p1 = position
        
        let maxRise = SCNFloat(10)
        let maxJump = SCNFloat(100.0)
        p0.y -= maxJump
        p1.y += maxRise
        
        
        let results = scene.physicsWorld.rayTestWithSegment(from: p1, to: p0, options: [SCNPhysicsWorld.TestOption.collisionBitMask : BitmaskGround , SCNPhysicsWorld.TestOption.searchMode: SCNPhysicsWorld.TestSearchMode.closest])
        let result = results[0]
        groundAltitude = result.worldCoordinates.y
        
        forCharacter.position.y = groundAltitude + Float(0.5)
    }
}
