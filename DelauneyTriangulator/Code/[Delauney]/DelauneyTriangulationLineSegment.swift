//
//  DelauneyTriangulationLineSegment.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/18/24.
//

import Foundation

class DelauneyTriangulationLineSegment {
    unowned var point1: DelauneyTriangulationPoint!
    unowned var point2: DelauneyTriangulationPoint!
    init(point1: DelauneyTriangulationPoint,
         point2: DelauneyTriangulationPoint) {
        self.point1 = point1
        self.point2 = point2
    }
    func clear() {
        point1 = nil
        point2 = nil
    }
}

extension DelauneyTriangulationLineSegment: Equatable {
    static func == (lhs: DelauneyTriangulationLineSegment, rhs: DelauneyTriangulationLineSegment) -> Bool {
        lhs.point1 === rhs.point1
    }
}

extension DelauneyTriangulationLineSegment: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(point1)
        hasher.combine(point2)
    }
}
