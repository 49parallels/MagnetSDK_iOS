//
//  Magnet.swift
//  Magnet
//
//  Created by e.d.neutrum on 18/10/2019.
//  Copyright © 2019 e.d.neutrum. All rights reserved.
//
import UIKit
import SceneKit
import ARKit
import Firebase

public class Magnet: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    
    private var sceneView: ARSCNView!
    //private var scene: SCNView!
    
    private var magnetManager: MagnetManager!
    
    private var videoPlayer: VideoPlayer?
    private var walls = [UUID: Canvas]()
    private var videoPlayers = [UUID: VideoPlayer]()
    private var streamStarted: Bool = false
    private var lastNode: SCNNode? = nil
    private var adWall: Canvas? = nil
    
    private var synced: Bool = false
    
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    
    public init(_ key: String, _ parent: UIView) {
        super.init()
        
        FirebaseApp.configure()
        MagnetDB.shared.configure()
        magnetManager = MagnetManager(key)
        
        sceneView = ARSCNView(frame: parent.frame)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        parent.addSubview(sceneView)
        
        resetTracking()
    }
    
    
    convenience override init() {
        self.init("", UIView(frame: CGRect.zero)) // calls above mentioned controller with default name
    }
    
    public func resetTracking() {
        clearNodes()
        
// LOCAL TEST
//
//        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
//            fatalError("Missing expected asset catalog resources.")
//        }
//
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.detectionImages = referenceImages
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        print(referenceImages)
        
        let configuration = ARImageTrackingConfiguration()

        if let referenceImages = magnetManager.getMagnetReferences() {
            print("referenceImages", referenceImages)
            configuration.maximumNumberOfTrackedImages = 10
            configuration.trackingImages = referenceImages

            // Run the view's session
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    
    func clearNodes() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        videoPlayers.forEach { (player) in
            player.value.pause()
        }
    }
    
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        
        updateQueue.async {
            if self.walls[anchor.identifier] == nil {
                
                let referenceName = imageAnchor.referenceImage.name!
                let videoMediaURL = NetworkConstants.apiURL+NetworkConstants.mediaEP+referenceName+"/480p.m3u8"
                
                print("Video Reference KEY:", referenceName, "URL:" ,videoMediaURL)
                self.videoPlayer = VideoPlayer(streamURL: URL(string: videoMediaURL)!, key: referenceName)
                
                let wall = Canvas(anchor: imageAnchor)
                self.walls[anchor.identifier] = wall
                
                // Create a SceneKit root node with the plane geometry to atta
                node.addChildNode(wall)
                
                self.sceneView.debugOptions = []
                if let videoPlayer = self.videoPlayer {
                    self.videoPlayers[anchor.identifier] = videoPlayer
                    wall.setMaterial(content: videoPlayer.scene)
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.videoPlayer?.play()
                }
                

                //self.displayWebView(on: wall, yOffset: imageAnchor.referenceImage.physicalSize.height, xOffset: imageAnchor.referenceImage.physicalSize.width)
            } else {
                self.videoPlayers[anchor.identifier]?.play()
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            if !imageAnchor.isTracked {
                print("not tracking anything")
//                videoPlayers.forEach { (player) in
//                    player.value.pause()
//                }
            }
        }
        
        if let anchor = anchor as? ARPlaneAnchor, let wall = walls[anchor.identifier] {
            wall.update(anchor: anchor)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("===Removed")
        if let anchor = anchor as? ARPlaneAnchor {
            walls.removeValue(forKey: anchor.identifier)
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print(error)
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
    
    
    
    private func localFileURL(fileName: String) -> URL {
        return Bundle.main.url(forResource: fileName, withExtension: "mp4")!
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func displayWebView(on rootNode: SCNNode, yOffset: CGFloat, xOffset: CGFloat) {
        // Xcode yells at us about the deprecation of UIWebView in iOS 12.0, but there is currently
        // a bug that does now allow us to use a WKWebView as a texture for our webViewNode
        // Note that UIWebViews should only be instantiated on the main thread!
        DispatchQueue.main.async {
            let request = URLRequest(url: URL(string: "https://16iwyl195vvfgoqu3136p2ly-wpengine.netdna-ssl.com/wp-content/uploads/2018/02/PVM-728-90px-01.gif")!)
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 728, height: 90))
            webView.loadRequest(request)
            
            let webViewPlane = SCNPlane(width: xOffset, height: 2.0)
            //webViewPlane.firstMaterial?.colorBufferWriteMask = .alpha
            webViewPlane.cornerRadius = 0.25
            
            let webViewNode = SCNNode(geometry: webViewPlane)
            
            // Set the web view as webViewPlane's primary texture
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
            //webViewNode.position.y += 0.5
            webViewNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
            webViewNode.position = SCNVector3Make(0, 0, Float(-(yOffset / 1.3)))
            webViewNode.opacity = 0
            
            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.sequence([
                .wait(duration: 3.0),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .wait(duration: 3.0),
                .fadeOpacity(to: 0.0, duration: 1.5),
                //.moveBy(x: 0, y: 0.0, z: -(yOffset / 1.3), duration: 1.5),
                //.moveBy(x: 0, y: 0.5, z: -0.05, duration: 0.2)
                ])
            )
        }
    }
    
    public func sync(completion: @escaping () -> Void) {
        print("Synchronizing ...")
        magnetManager.sync(completion: completion)
    }
}
