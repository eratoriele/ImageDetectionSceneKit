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
        let configuration = ARWorldTrackingConfiguration()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "trackImages", bundle: Bundle.main) else {
            return
        }

        configuration.detectionImages = trackedImages
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
            let cylinder = SCNCylinder(radius: 0.1, height: 0.5)
            cylinder.firstMaterial?.diffuse.contents = UIColor.cyan
            let ballNode = SCNNode(geometry: cylinder)
            
            ballNode.name = "node \(nodeID)"
            nodePositions[ballNode.name!] = ballNode.worldPosition
            nodeID += 1
            
            node.addChildNode(ballNode)
            ballNode.eulerAngles.x = -.pi / 2
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
        if anchor is ARImageAnchor {
            nodePositions.updateValue(node.childNodes[0].worldPosition, forKey: node.childNodes[0].name!)
                
            print("\n\n")
            for i in 0...nodePositions.count - 1 {

                print(nodePositions.count, " ", nodePositions["node \(i)"]!)
            }
            
            if (nodePositions.count > 1) {
                
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    if node.name == "planeplanenode" {
                        node.removeFromParentNode()
                    }
                }
                
                let centerx = (nodePositions["node 0"]!.x + nodePositions["node 1"]!.x) / 2
                let centery = (nodePositions["node 0"]!.y + nodePositions["node 1"]!.y) / 2
                let centerz = (nodePositions["node 0"]!.z + nodePositions["node 1"]!.z) / 2
                
                let width = nodePositions["node 0"]!.x - nodePositions["node 1"]!.x
                let height = nodePositions["node 0"]!.y - nodePositions["node 1"]!.y
                
                let plane = SCNPlane(width: CGFloat(abs(width)), height: CGFloat(abs(height)))
                plane.firstMaterial?.diffuse.contents = UIColor.red
                let planeNode = SCNNode(geometry: plane)
                
                //planeNode.eulerAngles.x = width * Float.pi
                //planeNode.eulerAngles.y = height * Float.pi
                //planeNode.eulerAngles.z = (nodePositions["node 0"]!.z - nodePositions["node 1"]!.z) * Float.pi
                
                planeNode.worldPosition = SCNVector3(centerx, centery, centerz)
                planeNode.name = "planeplanenode"
                
                sceneView.scene.rootNode.addChildNode(planeNode)
            }
            
        }
        
        
        
    }
}
