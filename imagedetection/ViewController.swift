//
//  ViewController.swift
//  imagedetection
//
//  Created by macos on 30.01.2020.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var nodePositions = [String: SCNVector3]()
    var nodeID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/empty.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "trackImages", bundle: Bundle.main) else {
            return
        }

        configuration.trackingImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 5
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
 
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if anchor is ARImageAnchor {
            let ball = SCNSphere(radius: 0.01)
            ball.firstMaterial?.diffuse.contents = UIColor.cyan
            let ballNode = SCNNode(geometry: ball)
            
            ballNode.name = "node \(nodeID)"
            nodePositions[ballNode.name!] = ballNode.worldPosition
            nodeID += 1
            
            node.addChildNode(ballNode)
        }
        
        return node
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else {
            return
        }
        
        print(node.worldPosition)
        //print(node.worldTransform)
        //print(node.worldOrientation)
        //print(node.simdWorldPosition)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else {
            return
        }
        
        nodePositions.updateValue(node.childNodes[0].worldPosition, forKey: node.childNodes[0].name!)
        
        print("\n\n")
        for i in 0...nodePositions.count - 1 {

            print(i, " ", nodePositions["node \(i)"]!)
        }
        
    }
}
