//
//  DelauneyTriangulationPoint.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/18/24.
//

import Foundation

class DelauneyTriangulationPoint {
    var x: Float
    var y: Float
    unowned var vertex: DelauneyTriangulationVertex!
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

extension DelauneyTriangulationPoint: Equatable {
    static func == (lhs: DelauneyTriangulationPoint, rhs: DelauneyTriangulationPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension DelauneyTriangulationPoint: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
