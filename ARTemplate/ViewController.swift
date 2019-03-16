//
//  ViewController.swift
//  ARTemplate
//
//  Created by aluno on 15/03/19.
//  Copyright © 2019 CESAR School. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = SCNDebugOptions.showFeaturePoints
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        importEarth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            createPlane(node: node, anchor: anchor)
        }
    }
    
    // PRIVATE METHODS..
    private func importEarth() {
        let scene = SCNScene(named: "art.scnassets/Earth.dae")!
        if let earthNode = scene.rootNode.childNode(withName: "Earth", recursively: true) {
            earthNode.position = SCNVector3(0, 1, -3)
            sceneView.scene.rootNode.addChildNode(earthNode)
        }
    }
    
    private func createEarth(vector: SCNVector3) {
        let scene = SCNScene(named: "art.scnassets/Earth.dae")!
        if let earthNode = scene.rootNode.childNode(withName: "Earth", recursively: true) {
            earthNode.position = vector
            
            let moveByVector = SCNVector3(0, 0.3, 0)
            earthNode.runAction(SCNAction.repeatForever(SCNAction.move(by: moveByVector, duration: 1)))
            
            let action = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 1)
            earthNode.runAction(SCNAction.repeatForever(action))
            
            sceneView.scene.rootNode.addChildNode(earthNode)
        }
    }
    
    let sofaSCNSceneArray = [SCNScene(named: "art.scnassets/sofa1.dae"),
                     SCNScene(named: "art.scnassets/sofa2.dae"),
                     SCNScene(named: "art.scnassets/sofa3.dae")]
    let sofaNameArray = ["sofa1", "sofa2", "sofa3"]
    var sofaContador = 0;
    
    private func createSofa(vector: SCNVector3) {
        // Validacao para o contador nao estourar o tamanho do array..
        if((sofaSCNSceneArray.count) == sofaContador) {
            sofaContador = 0
        }
        
        let scene = sofaSCNSceneArray[sofaContador]!
        if let earthNode = scene.rootNode.childNode(withName: sofaNameArray[sofaContador], recursively: true) {
            earthNode.position = vector
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.black
            
            scene.rootNode.geometry?.materials = [material]
            
            sceneView.scene.rootNode.addChildNode(earthNode)
        }
        
        if(sofaContador > 0) {
            sofaSCNSceneArray[sofaContador - 1]?.rootNode.childNodes.forEach({ (newNode) in
                newNode.removeFromParentNode()
            })
        }
        
        sofaContador += 1
    }
    
    var plane: SCNPlane?
    
    private func createPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        if(plane == nil) {
            plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.blue
            plane?.materials = [material]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                let vector = SCNVector3(
                    hitResult.worldTransform.columns.3.x,
                    hitResult.worldTransform.columns.3.y + 0.25,
                    hitResult.worldTransform.columns.3.z
                )
                
                //createEarth(vector: vector)
                createSofa(vector: vector)
            }
            else {
                let hits = sceneView.hitTest(touchLocation, options: nil)
                if let tappedNode = hits.first?.node {
                    tappedNode.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 7))
                }
            }
        }
    }
}
