//
//  TriangleSceneView.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//

import SwiftUI

struct TriangleSceneView: UIViewControllerRepresentable {
    
    @Environment(SceneViewModel.self) var sceneViewModel
    
    let width: CGFloat
    let height: CGFloat
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TriangleSceneView>) -> MetalViewController {
        
        //let width = Float(Int(width + 0.5))
        //let height = Float(Int(height + 0.5))
        
        let scene = TriangleScene(width: Float(width),
                                  height: Float(height))
        scene.sceneViewModel = sceneViewModel
        
        sceneViewModel.width = Float(width)
        sceneViewModel.height = Float(height)
        
        
        let metalViewController = MetalViewController(delegate: scene,
                                                      width: Float(width),
                                                      height: Float(height),
                                                      name: "Triangulation Demo")
        metalViewController.load()
        metalViewController.loadComplete()
        return metalViewController
    }
    
    func updateUIViewController(_ uiViewController: MetalViewController,
                                context: UIViewControllerRepresentableContext<TriangleSceneView>) {
        let width = Float(Int(width + 0.5))
        let height = Float(Int(height + 0.5))
        uiViewController.graphics.update(width: width,
                                         height: height)
        sceneViewModel.width = width
        sceneViewModel.height = height
    }
}
