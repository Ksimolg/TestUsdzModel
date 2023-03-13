//
//  ViewController.swift
//  BasicARApp
//
//  Created by Роман Исламов on 13.03.2023.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(handleTap(recognizer:))))
    }
    //Setup methods
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    // ObjPlacement
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        //logic of Raycast
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "vanilla_iced_latte", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Object placement failes - couldnt find surface.")
        }
    }
    // can mane only usdz model
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}


extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "vanilla_iced_latte" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
