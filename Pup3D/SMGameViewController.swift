//
//  SMGameViewController.swift
//  HopHop3D
//
//  Created by Martijn Bakker on 28/05/15.
//  Copyright (c) 2015 SydneyMae. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import CoreMotion
import SpriteKit



class SMGameViewController: UIViewController, animationDelegate /*, gameStateDelegate*/ {

//    static let sharedInstance = SMGameViewController()
    
    // Game view
//    public var gameView: SMGameView {
//        return view as! SMGameView
//    }
    
//    var sceneView : SMGameView!
    
    
    
//    var boneParticle: SCNParticleSystem!
    
    
    var gameSimulation : SMGameSimulation!
    
    var gameState : GameState?
    
    var spinner : UIActivityIndicatorView?
    
    var loadingScreenActive : Bool!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
//        start gameSimulation
//        gameSimulation = SMGameSimulation()
//        create a new scene

        // configure the loadingView
//        loadingScreenActive = true
//        blackBackground = UIView(frame: CGRectMake(0, 0, scnView.frame.size.width, scnView.frame.size.height))
//        blackBackground!.backgroundColor = UIColor.blueColor()
//        blackBackground!.layer.zPosition = 10
//        self.view.addSubview(blackBackground!)
    
//        _gameView.backgroundColor = UIColor.blackColor()
//        self.createSpinner()
//        blackBackground!.addSubview(spinner!)
//        spinner?.startAnimating()
//        spinner?.layer.zPosition = 100
        
//        set startingPosition
 //        set self as the delegate of gameView
//        gameSimulation.gameView.delegate = self
        
//        activate accelerometer
        
        
//        // add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
//        var gestureRecognizers = [AnyObject]()
//        gestureRecognizers.append(tapGesture)
//        if let existingGestureRecognizers = scnView.gestureRecognizers {
//            gestureRecognizers.extend(existingGestureRecognizers)
//        }
//        scnView.gestureRecognizers = gestureRecognizers
        
        // setup boneParticle system
        //self.setupBoneParticle()
        
        self.setGameState(GameState.preGame)
        
//        // Retrieve various game elements in one traversal
//        var collisionNodes = [SCNNode]()
//        scene.rootNode.enumerateChildNodesUsingBlock { (node, _) in
//            switch node.name {
//            
//            case let .Some(s) where s.rangeOfString("collision") != nil:
//                collisionNodes.append(node)
//            default:
//                break
//            }
//        }
//        
//        for node in collisionNodes {
//            node.hidden = false
//            setupCollisionNode(node)
//        }

        

    }
    
    func sceneView() -> SMGameView{
        return self.view as! SMGameView
    }
    
    override func loadView() {
        self.view = SMGameView()
    }
    


//    func handleTap(gestureRecognize: UIGestureRecognizer){
//        _gameSimulation.dogNode.physicsBody?.applyForce(SCNVector3Make(0,5,0), impulse: true)
//    }
    
//    func createSpinner() {
//        spinner = UIActivityIndicatorView(frame: CGRectMake(scnView.frame.size.width-25, scnView.frame.size.height-25, 50, 50))
//        spinner!.layer.cornerRadius = 5
//        spinner!.opaque = false
//        spinner!.backgroundColor = UIColor.clearColor()
//        spinner!.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//    }

    func rotateAnimation(_ node: SCNNode){
        let moveUp = SCNAction.moveBy(x: 0.0, y: 0.2, z: 0.0, duration: 1.0)
        let moveDown = SCNAction.moveBy(x: 0.0, y: -0.2, z: 0.0, duration: 1.0)
        let rotation = SCNAction.rotateBy(x: CGFloat(0.0), y: CGFloat(2*M_PI), z: CGFloat(0.0), duration: 2.0)
        
        let sequence = SCNAction.sequence([moveUp, moveDown])
        let repeatedSequenceUpDown = SCNAction.repeatForever(sequence)
        let repeatedSequenceRotate = SCNAction.repeatForever(rotation)
        node.runAction(repeatedSequenceUpDown)
        node.runAction(repeatedSequenceRotate)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    
//    func setupBoneParticle(){
//        boneParticle = SCNParticleSystem (named: "boneParticle", inDirectory: nil)
//    }
    
    

    func setGameState(_ gameState : GameState){
        if gameState == gameState{
            return
        }
//        println("inGameGUIView = \(_inGameGUIView)")
//        _inGameGUIView.setGameState(gameState)
        
//        _gameState = gameState
    }
    
    func dogJump(){
        gameSimulation.mainCharacter.physicsBody?.applyForce(SCNVector3Make(0,5,0), asImpulse: true)
    }
    
    

    
    
    
//    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
//        
//    }

//    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
//        
//    }
    
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.landscape]
        
        return orientation
    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func togglePaused(){
        if gameState == GameState.paused{
            self.setGameState(GameState.inGame)
        }else if gameState == GameState.inGame{
            self.setGameState(GameState.paused)
        }
    }
}
