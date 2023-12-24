//
//  ControlsView.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//

import SwiftUI

struct ControlsView: View {
    @Environment(SceneViewModel.self) var sceneViewModel
    
    var body: some View {
        @Bindable var sceneViewModel = sceneViewModel
        VStack {
            
            HStack {
                HStack {
                    TextField(text: $sceneViewModel.polygonPointCountString) {
                        Text("Point Count")
                    }
                    
                    Button(action: {
                        let count = Int(sceneViewModel.polygonPointCountString) ?? 32
                        sceneViewModel.generateRandomPolygon(width: sceneViewModel.width,
                                                             height: sceneViewModel.height,
                                                             count: count)
                    }, label: {
                        Text("Random Polygon")
                    })
                    .buttonStyle(.borderedProminent)
                }
                
                HStack {
                    TextField(text: $sceneViewModel.polygonPointCountString) {
                        Text("Point Count")
                    }
                    
                    Button(action: {
                        let count = Int(sceneViewModel.polygonPointCountString) ?? 32
                        sceneViewModel.generateRandomPolygon(width: sceneViewModel.width,
                                                             height: sceneViewModel.height,
                                                             count: count)
                    }, label: {
                        Text("Random Polygon")
                    })
                    .buttonStyle(.borderedProminent)
                }
                
            }
            
            Picker("", selection: $sceneViewModel.triangulationMode) {
                
                ForEach(SceneViewModel.TriangulationMode.allCases) { triangulationMode in
                    Text(triangulationMode.description).tag(triangulationMode)
                }
                
                        }
                        .pickerStyle(.segmented)
            
        }
        .frame(width: 800, height: 120)
        .background(Color.red)
    }
}

#Preview {
    ControlsView()
}
