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

// Collision bit masks
let BitmaskCollision        = 1 << 2
let BitmaskCollectable      = 1 << 3
let BitmaskEnemy            = 1 << 4
let BitmaskSuperCollectable = 1 << 5
let BitmaskWater            = 1 << 6

class SMGameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, animationDelegate /*, gameStateDelegate*/ {

//    static let sharedInstance = SMGameViewController()
    
    // Game view
    var gameView: SMGameView {
        return view as! SMGameView
    }
    
//    var scene : SCNScene!
    
    var run : SCNAction!
    
    var rotate : SCNAction!
    
    var move : SCNMatrix4!
    
    var convert : SCNMatrix4!
    
    var motionManager: CMMotionManager!
    var dogSpeed:Float = 0.25
    var running: Bool = false
    
    var boneParticle: SCNParticleSystem!
    var cameraNode: SCNNode!
    
    var gameSimulation: SMGameSimulation!
    
    var gameState : GameState?
    
    var spinner : UIActivityIndicatorView?
    
    var loadingScreenActive : Bool!
    
    var mainCharacter : SCNNode!
    
    var spotLightNode: SCNNode!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        create a new scene
        let scene = SCNScene(named: "art.scnassets/level.scn")
        
        let level = scene?.rootNode.childNodeWithName("levelGroup", recursively: true)
        
        print(level)
        print(level?.position)
        
//        add scene to gameview
        gameView.scene = scene
        
//        stats, comment out for production
        self.gameView.allowsCameraControl = true
        self.gameView.showsStatistics = true
        
//        start gameSimulation
        gameSimulation = SMGameSimulation()
        
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
        
//        Add the character to the scene.
        mainCharacter = gameSimulation.makeMainCharacterNode()
        let startPosition = scene?.rootNode.childNodeWithName("startingPoint", recursively: true)
        
        
        
        scene?.rootNode.addChildNode(mainCharacter)
        mainCharacter.transform = startPosition!.transform
        print(mainCharacter.position)

//         setup lights
        setupLights()
        
//        setup camera
        self.setupCamera()
        let mainChar = scene?.rootNode.childNodeWithName("dog", recursively: true)
//        create child node of main character for camera to follow
        let emptyNode = SCNNode()
        mainCharacter!.addChildNode(emptyNode)
        emptyNode.position = SCNVector3Make(-1, 0.5, 0)
        
//        place camera behind mainCharacter
//        let targetCameraNode = SCNLookAtConstraint(target: mainCharacter);
//        targetCameraNode.gimbalLockEnabled = true;
//        cameraNode.constraints = [targetCameraNode];
        
        mainCharacter!.addChildNode(cameraNode)
        print(mainChar)
//        set active camera
        gameView.pointOfView = cameraNode
        
//        set self as the delegate of gameView
        gameView.delegate = self
        
//        activate accelerometer
        self.setupAccelerometer()
        
//        // add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
//        var gestureRecognizers = [AnyObject]()
//        gestureRecognizers.append(tapGesture)
//        if let existingGestureRecognizers = scnView.gestureRecognizers {
//            gestureRecognizers.extend(existingGestureRecognizers)
//        }
//        scnView.gestureRecognizers = gestureRecognizers
        
        //set SpriteKit overlay view (GUI)
//        _inGameGUIView = SMGameView(size: _gameView.bounds.size)
//        _gameView.overlaySKScene = _inGameGUIView
//        
//        _inGameGUIView._animationDelegate = self
//        _inGameGUIView._gameStateDelegate = self
        
        // rotate bones
        //self.rotateAnimation(_gameSimulation._boneNode)
        
        // setup boneParticle system
        //self.setupBoneParticle()
        
//        set physicsworld delegate and gravity
        scene!.physicsWorld.contactDelegate = self
//        scene!.physicsWorld.gravity = SCNVector3Make(0, -9.8, 0)
        
        self.setGameState(GameState.preGame)
        
        move = SCNMatrix4MakeTranslation(0.1, 0, 0)
        
        
        let targetSpotlightConstraint = SCNLookAtConstraint(target: mainCharacter)
        targetSpotlightConstraint.gimbalLockEnabled = true
        spotLightNode.constraints = [targetSpotlightConstraint]
        self.mainCharacter.addChildNode(spotLightNode)


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
    
       
    
    
    func rotateAnimation(node: SCNNode){
        let moveUp = SCNAction.moveByX(0.0, y: 0.2, z: 0.0, duration: 1.0)
        let moveDown = SCNAction.moveByX(0.0, y: -0.2, z: 0.0, duration: 1.0)
        let rotation = SCNAction.rotateByX(CGFloat(0.0), y: CGFloat(2*M_PI), z: CGFloat(0.0), duration: 2.0)
        
        let sequence = SCNAction.sequence([moveUp, moveDown])
        let repeatedSequenceUpDown = SCNAction.repeatActionForever(sequence)
        let repeatedSequenceRotate = SCNAction.repeatActionForever(rotation)
        node.runAction(repeatedSequenceUpDown)
        node.runAction(repeatedSequenceRotate)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.setGameState(GameState.inGame)
        
//        var _skScene = scnView.overlaySKScene
        let touch = touches.first
//        let point = touch!.locationInNode(_inGameGUIView)
//        _inGameGUIView.touchUpAtPoint(point)
        super.touchesEnded(touches, withEvent: event)
        
    }
    
    
    func setupBoneParticle(){
        boneParticle = SCNParticleSystem (named: "boneParticle", inDirectory: nil)
    }
    
    func setupCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.name = "camera"
        cameraNode.camera!.zFar = 200
        cameraNode.camera?.xFov = 75
        cameraNode.position = SCNVector3Make(-3,1 ,0)
        cameraNode.rotation = SCNVector4Make(0, 1, 0, Float( -M_PI_2))
    }
    
    func renderer(aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        
        
        
//        if _gameState == GameState.inGame{
//            println("inGame")
//        }else if _gameState == GameState.paused{
//            println("paused")
//        }else if _gameState == GameState.preGame{
//            println("pregame")
//        }
//        if _gameState == GameState.inGame{
        
//        }
//        self._gameSimulation.moveDogNode()
        

    }
    func renderer(renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
            
//        if (loadingScreenActive == true){
//            println("remove loadingscreen called")
//        spinner?.stopAnimating()
//        spinner?.removeFromSuperview()
//        blackBackground?.removeFromSuperview()
//            loadingScreenActive = false
//        }
//        mainCharacter.runAction(run)
        
        
        convert = mainCharacter.convertTransform(move, toNode: nil)
        
        
        
        run = SCNAction.moveTo(SCNVector3Make(convert.m41, convert.m42, convert.m43), duration: 1/60)
        mainCharacter.runAction(run)
        mainCharacter.runAction(rotate)
        
        if (self.running == true){
            gameSimulation.setInRunAnimation(true)
        }else{
            gameSimulation.setInRunAnimation(false)
        }
        
    }
    

    
    func setGameState(gameState : GameState){
        if gameState == gameState{
            return
        }
//        println("inGameGUIView = \(_inGameGUIView)")
//        _inGameGUIView.setGameState(gameState)
        
//        _gameState = gameState
        
        
        
    }
    
    func dogJump(){
        mainCharacter.physicsBody?.applyForce(SCNVector3Make(0,5,0), impulse: true)
    }
    
    

    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
            if contact.nodeA.physicsBody?.categoryBitMask == PhysicsCategory.bone{
//                _gameSimulation._boneNode.addParticleSystem(_boneParticle)
                score++
            }
    }
    
    
//    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
//        
//    }

//    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
//        
//    }
    
    func setupAccelerometer(){
        //setup motionmanager
        motionManager = CMMotionManager()
        if motionManager.accelerometerAvailable{
            motionManager.accelerometerUpdateInterval = 1/60.0
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()){
                (data, error) in
                
                let threshold = 0.20
                
                //move right
                if data!.acceleration.y < -threshold{

                    let direction = -(CGFloat(data!.acceleration.y) * CGFloat(M_PI*(1/64)))
//                    let turn = SCNAction.rotateByAngle(CGFloat(1/8*M_PI)*CGFloat(directionZ), aroundAxis: SCNVector3Make(0, -1, 0), duration: 1/60)
//                    self._motionManager.accelerometerActive == true
//                    let action = SCNAction.moveBy(SCNVector3Make(0, 0, directionZ), duration: 1/60)
//                    self._gameSimulation._dogNode.runAction(turn)
//                    self._gameSimulation.moveDogNodeWithAngularVelocity(SCNVector4Make(0, -1, 0, directionZ))
                    
//                    self._gameSimulation._rotation = SCNVector4Make(0, 1, 0, directionZ)
                    self.rotate = SCNAction.rotateByAngle(direction, aroundAxis: SCNVector3Make(0, 1, 0), duration: 1/60)
                    
                    self.running = true
                    
                }
                //move left
                else if data!.acceleration.y > threshold{

                    let direction = -(CGFloat(data!.acceleration.y) * CGFloat(M_PI*(1/64)))
//                    let turn = SCNAction.rotateByAngle(CGFloat(1/8*M_PI)*CGFloat(directionZ), aroundAxis: SCNVector3Make(0, -1, 0), duration: 1/60)
//                    self._motionManager.accelerometerActive == true
//                    let action = SCNAction.moveBy(SCNVector3Make(0, 0, directionZ), duration: 1/60)
                    
//                    self._gameSimulation._dogNode.runAction(turn)
//                    self._gameSimulation.moveDogNodeWithAngularVelocity(SCNVector4Make(0, -1, 0, directionZ))
                    
//                    self._gameSimulation._rotation = SCNVector4Make(0, 1, 0, directionZ)
                    self.rotate = SCNAction.rotateByAngle(direction, aroundAxis: SCNVector3Make(0, 1, 0), duration: 1/60)
                    
                    
                    self.running = true
                    
                }
                else{
                    self.running = true
//                    self._gameSimulation._rotation = SCNVector4Make(0, 0, 0, 0)
                    self.rotate = SCNAction.rotateByAngle(0, aroundAxis: SCNVector3Make(0, 0, 0), duration: 1/60)
                    
                }
            }
        }
    }
    

    

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Landscape]
        
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
    
    func setupLights(){
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light?.type = SCNLightTypeAmbient
//        ambientLightNode.light?.color = UIColor(white: 0.5, alpha: 1.0)
//        ambientLightNode.name = "ambientLight"
//        
//        gameView.scene!.rootNode.addChildNode(ambientLightNode)
        
        
        spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light?.type = SCNLightTypeSpot
        spotLightNode.light?.color = UIColor(white: 0.7, alpha: 1.0)
        spotLightNode.position = SCNVector3Make(4, 10, 4)
        spotLightNode.rotation = SCNVector4Make(1, 0, 0, Float(-M_PI/2.8))
        spotLightNode.light?.spotInnerAngle = 0
        spotLightNode.light?.spotOuterAngle = 30
        spotLightNode.light?.shadowColor = UIColor .blackColor()
        spotLightNode.light?.zFar = 100
        spotLightNode.light?.zNear = 1
        spotLightNode.name = "spotLight"
        spotLightNode.light!.castsShadow = true
        
        gameView.scene!.rootNode.castsShadow = true;
    }

    
        
            
        

}
