//
//  DelauneyTriangulationFace.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/18/24.
//

import Foundation

class DelauneyTriangulationFace {
    var edge: DelauneyTriangulationEdge
    init(edge: DelauneyTriangulationEdge) {
        self.edge = edge
    }
}

extension DelauneyTriangulationFace: Equatable {
    static func == (lhs: DelauneyTriangulationFace, rhs: DelauneyTriangulationFace) -> Bool {
        lhs === rhs
    }
}

extension DelauneyTriangulationFace: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
