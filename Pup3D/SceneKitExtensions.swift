//
//  SceneKitExtensions.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 13/12/15.
//  Copyright © 2015 SydneyMae. All rights reserved.
//

import SceneKit
import SpriteKit

extension float2 {
    init(_ v: CGPoint) {
        self.init(Float(v.x), Float(v.y))
    }
}

extension SCNNode {
    var boundingBox: (min: SCNVector3, max: SCNVector3) {
        get {
            var min = SCNVector3(0, 0, 0)
            var max = SCNVector3(0, 0, 0)
            getBoundingBoxMin(&min, max: &max)
            return (min, max)
        }
    }
}

extension CAAnimation {
    class func animationWithSceneNamed(name: String) -> CAAnimation? {
        var animation: CAAnimation?
        if let scene = SCNScene(named: name) {
            scene.rootNode.enumerateChildNodesUsingBlock({ (child, stop) in
                if child.animationKeys.count > 0 {
                    animation = child.animationForKey(child.animationKeys.first!)
                    stop.initialize(true)
                }
            })
        }
        return animation
    }
}