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


class SMAnimatedCharacter : SCNNode{
    
    var mainSkeleton:SCNNode!
    
    
    init(characterNode: SCNNode){
        super.init()
        
        self.addChildNode(characterNode)
//        characterNode.position = SCNVector3Make(0, 0, 0)
        self.enumerateChildNodesUsingBlock(){
            (node, stop) -> Void in
            if node.skinner != nil{
                self.mainSkeleton = node.skinner!.skeleton
            }
        }
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cachedAnimationForKey(key: String) -> CAAnimation{
        return _animationsDictionary[key]!
    }
    
    func loadAnimationNamed(animationName:String) -> CAAnimation{
        let animation = CAAnimation.animationWithSceneNamed("art.scnassets/mainCharacterRun.scn")
        
        animation!.fadeInDuration = 0.3
        animation!.fadeOutDuration = 0.3
        return animation!
        
    }
    
//    func loadAnimationNamed(animationName:String, sceneName:String) -> CAAnimation{
//
//        let url = NSBundle.mainBundle().URLForResource(sceneName, withExtension: "scn")
//        let sceneSource = SCNSceneSource(URL: url!, options: nil)
//        let animation = sceneSource?.entryWithIdentifier(animationName, withClass: CAAnimation.self)
//
//        animation!.fadeInDuration = 0.3
//        animation!.fadeOutDuration = 0.3
//        
//        return animation!
//    }
    
    func loadAndCacheAnimation( daeFile: String, name: String, key:String) ->CAAnimation{
        if _animationsDictionary == nil{
            _animationsDictionary = [:]
        }
//        let ext = ".scn"
//        daeFile.appendContentsOf(ext)
        
        let anim : CAAnimation? = loadAnimationNamed(name)
        print(anim)
        if (anim != nil) {
            _animationsDictionary[key] = anim
            anim!.delegate = self
        }
        
        return anim!
    }
        
    func chainAnimation2(firstKey:String, secondKey:String, fadeTime:CGFloat){
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
        
    func chainAnimation1(firstKey:String, secondKey:String){
        chainAnimation2(firstKey, secondKey: secondKey, fadeTime: 0.85)
    }
    
    func update(deltaTime:NSTimeInterval){
        
    }
}