//
//  SMMainCharacter.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 28/05/15.
//  Copyright (c) 2015 SydneyMae. All rights reserved.
//

import SceneKit



enum DogAnimation : Int{
    case idle
    case run
//    case runRight
    case turn
    case jumpStart
    case jump
    case jumpEnd
}

//private typealias ParticleEmitter = (_node: SCNNode, particleSystem: SCNParticleSystem, birthRate: CGFloat)

class SMMainCharacter : SCNNode{
    
//    let node = SCNNode()
    
//    let characterTopLevelNode : SCNNode!
    
    var inRunAnimation: Bool! = false

    init(characterNode: SCNNode){
        super.init()
        //        setupIdleAnimation()
//        setupRunAnimation()
    
        
        // The character is loaded from a .scn file and stored in an intermediate
        // node that will be used as a handle to manipulate the whole group at once
        
        
        
        
        
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
//    func setupIdleAnimation(){
//        let idleAnimation : CAAnimation? = loadAndCacheAnimation2("art.scnassets/objects/dog/dogIdle", key: keyForAnimationType(DogAnimation.idle))
//        if idleAnimation != nil{
//            idleAnimation?.repeatCount = FLT_MAX
//            idleAnimation?.fadeInDuration = 0.15
//            idleAnimation?.fadeOutDuration = 0.15
//        }
//        
//    }
//    
//    
    
    
}