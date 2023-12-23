//
//  ContainerView.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//

import SwiftUI

struct ContainerView: View {
    
    @Environment(SceneViewModel.self) var sceneViewModel
    
    var body: some View {
        VStack(spacing: 0.0) {
            ControlsView()
            GeometryReader { geometry in
                TriangleSceneView(width: geometry.size.width,
                                  height: geometry.size.height)
            }
        }
    }
}

#Preview {
    ContainerView()
}
