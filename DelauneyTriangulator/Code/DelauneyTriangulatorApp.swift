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
                    
                    struct MyPoint: PointProtocol {
                        var x: Float
                        var y: Float
                    }

                    let points = [
                        MyPoint(x: -100.0, y: -100.0),
                        MyPoint(x: 100.0, y: -100.0),
                        MyPoint(x: 0.0, y: 0.0),
                        MyPoint(x: 0.0, y: 100.0)
                    ]

                    let triangulator = DelauneyTriangulator.shared
                    triangulator.triangulate(points: points,
                                             pointCount: points.count)

                    var triangleIndex = 0
                    while triangleIndex < triangulator.triangleCount {
                        let triangle = triangulator.triangles[triangleIndex]
                        
                        let point1 = triangle.point1
                        let point2 = triangle.point2
                        let point3 = triangle.point3
                        
                        print("Triangle[\(triangleIndex)].point1 = (\(point1.x), \(point1.y))")
                        print("Triangle[\(triangleIndex)].point2 = (\(point2.x), \(point2.y))")
                        print("Triangle[\(triangleIndex)].point3 = (\(point3.x), \(point3.y))")
                        
                        triangleIndex += 1
                    }
                    
                    
                }
        }
    }
}
