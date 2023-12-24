//
//  DelauneyTriangulatorApp.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//

import SwiftUI

@main
struct DelauneyTriangulatorApp: App {
    
    @State var sceneViewModel = SceneViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContainerView()
                .environment(sceneViewModel)
                .onAppear {
                    
                let hull = [
                    SIMD2<Float>(-100.0, -100.0),
                    SIMD2<Float>(100.0, -100.0),
                    SIMD2<Float>(0.0, 100.0)
                ]

                let points = [
                    SIMD2<Float>(-25.0, -10.0),
                    SIMD2<Float>(50.0, 10.0)
                ]

                DelauneyTriangulator.shared.delauneyConstrainedTriangulation(points: points,
                                                                             hull: hull)

                for triangle in DelauneyTriangulator.shared.triangles {
                    print("Triangle: [(\(triangle.point1.x), \(triangle.point1.y)), (\(triangle.point2.x), \(triangle.point2.y)), (\(triangle.point3.x), \(triangle.point3.y))]")
                }
                    
                    
                }
        }
    }
}
