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
let BitmaskMainCharacter    = 1 << 1
let BitmaskGround           = 1 << 2
let BitmaskCollision        = 1 << 3
let BitmaskCollectable      = 1 << 4
let BitmaskEnemy            = 1 << 5


class SMGameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, animationDelegate /*, gameStateDelegate*/ {

//    static let sharedInstance = SMGameViewController()
    
    // Game view
    var gameView: SMGameView {
        return view as! SMGameView
    }
    
    var scene : SCNScene!

    
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
    
    var mainCharacterSpeed : Float = 0.0
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        create a new scene
        scene = SCNScene(named: "art.scnassets/world.scn")
        
//        setup collision details of all the level nodes
        self.levelCollision()
        
        
//        add scene to gameview
        gameView.scene = scene
        
//        stats, comment out for production
        self.gameView.allowsCameraControl = false
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

//         setup lights
        setupLights()
        
//        setup camera
        self.setupCamera()
//        create empty child node of main character for camera to follow
        let emptyNode = SCNNode()
        mainCharacter!.addChildNode(emptyNode)
        emptyNode.position = SCNVector3Make(-1, 0.5, 0)
        
        
        mainCharacter!.addChildNode(cameraNode)
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
        
        // setup boneParticle system
        //self.setupBoneParticle()
        
//        set physicsworld delegate and gravity
        scene!.physicsWorld.contactDelegate = self
        scene!.physicsWorld.gravity = SCNVector3Make(0, -9.8, 0)
        
//        setup collision and catergory bitmasks for individual nodes
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "craneNode")
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "trashNode")
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "trafficLightNode")
        self.setCategoryBitmask(BitmaskCollision, andCollisionBitmask: BitmaskMainCharacter, forNode: "lampPostNode")
        
        
        self.setGameState(GameState.preGame)
        
        
        
        let targetSpotlightConstraint = SCNLookAtConstraint(target: mainCharacter)
        targetSpotlightConstraint.gimbalLockEnabled = true
        spotLightNode.constraints = [targetSpotlightConstraint]
        self.mainCharacter.addChildNode(spotLightNode)
        
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

        self.addBeachBall()

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
    
    func levelCollision(){
//        simplified version, in final version enumerate over all the childnodes of "levelgroup" and assign each node it's own convexhull physicsShapeType for a more detailed collision mesh. Enumerate over nodes, place them in an array and "for-loop" the array to add the collisionshape
        let level = scene?.rootNode.childNodeWithName("levelGroup", recursively: true)
//        set to convexhull when method described above is implemented
        level?.physicsBody = SCNPhysicsBody(type: .Static, shape: SCNPhysicsShape(node: level!, options: [SCNPhysicsShapeTypeKey:SCNPhysicsShapeTypeConcavePolyhedron]))
        
        level?.physicsBody?.categoryBitMask = BitmaskGround
    }
    
    
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        mainCharacterSpeed = 0.1
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        mainCharacterSpeed = 0
        
        self.setGameState(GameState.inGame)
        
//        var _skScene = scnView.overlaySKScene
        _ = touches.first
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
        
        cameraNode.position = SCNVector3Make(-4,2 ,0)
        cameraNode.eulerAngles = SCNVector3Make(Float(-M_PI_4)/3, Float(-M_PI_2), 0)
            }
    
    func renderer(aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        
        gameSimulation.controlCharacterAltitude(scene)
        
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
    func renderer(renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
            
//        if (loadingScreenActive == true){
//            println("remove loadingscreen called")
//        spinner?.stopAnimating()
//        spinner?.removeFromSuperview()
//        blackBackground?.removeFromSuperview()
//            loadingScreenActive = false
//        }
//        mainCharacter.runAction(run)
        
        move = SCNMatrix4MakeTranslation(mainCharacterSpeed, 0, 0)
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
    
    func addBeachBall(){
        let ball = SCNNode()
        ball.position = SCNVector3Make(15, 20, 160);
        ball.geometry = SCNSphere(radius: 0.4)
        ball.geometry!.firstMaterial!.locksAmbientWithDiffuse = true;
        ball.geometry!.firstMaterial!.diffuse.contents = "art.scnassets/textures/ballDiffuse.jpg";
        ball.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 1, 1);
        ball.geometry!.firstMaterial!.diffuse.wrapS = SCNWrapMode.Mirror
        ball.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry:ball.geometry!, options: [SCNPhysicsShapeTypeKey:SCNPhysicsShapeTypeBoundingBox]))
        ball.physicsBody!.restitution = 0.9;
        ball.physicsBody?.collisionBitMask = BitmaskMainCharacter | BitmaskGround
        ball.physicsBody?.categoryBitMask = BitmaskCollision
//        ball.physicsBody?.collisionBitMask = BitmaskMainCharacter
        scene.rootNode.addChildNode(ball)
    }
    
    func setCategoryBitmask(category:Int, andCollisionBitmask collision:Int, forNode node:String){
        let node = scene.rootNode.childNodeWithName(node, recursively: true)
        node?.physicsBody?.collisionBitMask = collision
        node?.physicsBody?.categoryBitMask = category
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
                    self.rotate = SCNAction.rotateByAngle(direction, aroundAxis: SCNVector3Make(0, 1, 0), duration: 1/60)
                    
                    self.running = true
                    
                }
                //move left
                else if data!.acceleration.y > threshold{

                    let direction = -(CGFloat(data!.acceleration.y) * CGFloat(M_PI*(1/64)))
                    self.rotate = SCNAction.rotateByAngle(direction, aroundAxis: SCNVector3Make(0, 1, 0), duration: 1/60)
                    
                    self.running = true
                    
                }
                else{
                    self.running = true
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
