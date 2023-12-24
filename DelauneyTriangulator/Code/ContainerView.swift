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
                .onAppear {
                    let polygonCount = Int(sceneViewModel.polygonPointCountString) ?? 32
                    sceneViewModel.generateRandomPolygon(width: Float(geometry.size.width),
                                                         height: Float(geometry.size.height),
                                                         count: polygonCount)
                    
                    let innerPointCount = Int(sceneViewModel.innerPointCountString) ?? 64
                    sceneViewModel.generateRandomPoints(width: Float(geometry.size.width),
                                                        height: Float(geometry.size.height),
                                                        count: innerPointCount)
                    
                    /*
                    var safety = 0
                    while safety < 1_000_000 {
                        
                        if (safety % 100) == 0 {
                            print("Safety: \(safety)")
                        }
                        
                        sceneViewModel.generateRandomPolygon(width: Float(geometry.size.width),
                                                             height: Float(geometry.size.height),
                                                             count: polygonCount)
                        sceneViewModel.generateRandomPoints(width: Float(geometry.size.width),
                                                            height: Float(geometry.size.height),
                                                            count: innerPointCount)
                        
                        DelauneyTriangulator.shared.triangulate(points: sceneViewModel.innerPoints.map { .init($0.x, $0.y) },
                                                                
                                                                hull: sceneViewModel.polygon.map { .init($0.x, $0.y) })
                        if DelauneyTriangulator.shared.triangles.count == 0 {
                            break
                        } else {
                            safety += 1
                        }
                        
                    }
                    */
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .background(Color.black)
    }
}

#Preview {
    ContainerView()
}
