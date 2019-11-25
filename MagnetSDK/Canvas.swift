//
//  Canvas.swift
//  kAR
//
//  Created by Tomas Vajdicka on 09/04/2019.
//  Copyright © 2019 rebel.io. All rights reserved.
//

import ARKit
import UIKit
import SceneKit

class Canvas: SCNNode {
    
    //private let anchor:
    private let plane: SCNPlane
    private let planeNode: SCNNode
    private let rotated: MagnetOrientation
    
    init(anchor: ARImageAnchor) {
        //self.anchor = anchor
        let x = anchor.transform
        // !!!! must be in METERS !!!!
        let width = anchor.referenceImage.physicalSize.width
        let height = anchor.referenceImage.physicalSize.height
        
        self.rotated = MagnetOrientation(rawValue: anchor.referenceImage.accessibilityValue ?? MagnetOrientation.UP.rawValue) ?? MagnetOrientation.UP
        self.plane = SCNPlane(width: CGFloat(width), height: height)
        self.planeNode = SCNNode(geometry: self.plane)
        
        super.init()
        
        plane.firstMaterial = Canvas.makeDefaultPlaneMaterial()
        planeNode.position = SCNVector3(x.columns.3.x, 1.0, x.columns.3.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
        
        updateMaterialDiffuseScale()
        
        self.addChildNode(planeNode)
    }
    
    func setMaterial(content: AnyObject?) {
        guard let material = plane.materials.first else { return }
        
        material.diffuse.contents = content
    }
    
    /// This method will update the plane when it changes.
    ///
    /// - Parameter anchor: the ARPlaneAnchor
    func update(anchor: ARPlaneAnchor) {
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        
        position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        // update the material representation for this plane
        updateMaterialDiffuseScale()
    }
    
    private static func makeDefaultPlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.50)
        return material
    }
    
    /// Scale the diffuse component of the material
    private func updateMaterialDiffuseScale() {
        guard let material = plane.materials.first else { return }
        print("planeW:", plane.width, "planeH:", plane.height)
//        let width = Float(self.plane.width)
//        let height = Float(self.plane.height)
//        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
//        if self.rotated == MagnetOrientation.LEFT {
//            let translation = SCNMatrix4MakeTranslation(0, -1, 0)
//            let rotation = SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, 1)
//            let transform = SCNMatrix4Mult(translation, rotation)
//            material.diffuse.contentsTransform = transform
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
