//
//  DelauneyTriangulationTriangle.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/18/24.
//

import Foundation

class DelauneyTriangulationTriangle {
    var point1: DelauneyTriangulationPoint
    var point2: DelauneyTriangulationPoint
    var point3: DelauneyTriangulationPoint
    init(point1: DelauneyTriangulationPoint,
         point2: DelauneyTriangulationPoint,
         point3: DelauneyTriangulationPoint) {
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
    }
}
