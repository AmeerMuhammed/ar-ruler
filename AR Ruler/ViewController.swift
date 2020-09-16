//
//  ViewController.swift
//  AR Ruler
//
//  Created by AmeerMuhammed on 9/12/20.
//  Copyright © 2020 AmeerMuhammed. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitTestResult = hitTestResults.first {
                addDot(at: hitTestResult)
            }
        }
    }
    
    // MARK: - Ruler Methods
    
    func addDot(at location : ARHitTestResult) {
        
        let dotSphere = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotSphere.materials = [material]
        
        let dotNode = SCNNode(geometry: dotSphere)
        dotNode.position = SCNVector3(location.worldTransform.columns.3.x, location.worldTransform.columns.3.y, location.worldTransform.columns.3.z)
        
        if (dotNodes.count>=2) { resetMeasures() }
        dotNodes.append(dotNode)
        sceneView.scene.rootNode.addChildNode(dotNode)
        if(dotNodes.count>=2) { calculateDistance() }
    }
    
    func calculateDistance() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(pow((end.position.x - start.position.x),2)+pow((end.position.y - start.position.y),2)+pow((end.position.z - start.position.z),2))
        
        showText(text: "\(distance)",position: end.position)
        
    }
    
    func showText(text:String, position: SCNVector3) {
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode.geometry = textGeometry
        textNode.position = position
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func resetMeasures() {
        for dotNode in dotNodes
        {
            dotNode.removeFromParentNode()
        }
        dotNodes = [SCNNode]()
        textNode.removeFromParentNode() 
    }
}
