//
//  ViewController.swift
//  ARPortal
//
//  Created by Marko Jovanov on 1.9.21.
//
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneViewTap = sender.view as? ARSCNView else { return }
        let touchLocation = sender.location(in: sceneViewTap)
        let hitTestResult = sceneViewTap.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            addPortal(hitTestResult: hitTestResult.first!)
        }
    }
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "art.scnassets/Portal.scn")
        if let portalNode = portalScene?.rootNode.childNode(withName: "Portal", recursively: false) {
            let transform = hitTestResult.worldTransform
            portalNode.position = SCNVector3(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z
            )
            sceneView.scene.rootNode.addChildNode(portalNode)
            addPlane(nodeName: "roof", portalNode: portalNode, imageName: "top")
            addPlane(nodeName: "plane", portalNode: portalNode, imageName: "bottom")
            addWalls(nodeName: "backWall", portalNode: portalNode, imageName: "back")
            addWalls(nodeName: "leftWall", portalNode: portalNode, imageName: "sideA")
            addWalls(nodeName: "rightWall", portalNode: portalNode, imageName: "sideB")
            addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "sideDoorA")
            addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "sideDoorB")
        }
    }
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/\(imageName).png")
        child?.renderingOrder = 200
    }
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/\(imageName).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
        
    }
}
