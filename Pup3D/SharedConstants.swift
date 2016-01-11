//
//  SharedConstants.swift
//  PuppyQuest3D
//
//  Created by Martijn Bakker on 03/06/15.
//  Copyright (c) 2015 DeltaStudios. All rights reserved.
//

import Foundation

struct PhysicsCategory {
    static let dog          = 1
    static let bird         = 2
    static let level        = 4
    static let fireCrane    = 8
    static let bone         = 16
    static let parkBench    = 32
}

enum GameState : Int{
    case preGame = 0
    case inGame
    case paused
    case postGame
    case count
}

var score: Int = 0
