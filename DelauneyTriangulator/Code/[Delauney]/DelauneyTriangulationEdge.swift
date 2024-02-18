//
//  DelauneyTriangulationEdge.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/18/24.
//

import Foundation

class DelauneyTriangulationEdge {
    init(vertex: DelauneyTriangulationVertex) {
        self.vertex = vertex
    }
    
    var vertex: DelauneyTriangulationVertex
    var face: DelauneyTriangulationFace!
    var nextEdge: DelauneyTriangulationEdge!
    var oppositeEdge: DelauneyTriangulationEdge!
    var previousEdge: DelauneyTriangulationEdge!
    
    var isBucketed = false
    var isTagged = false
    
    func clear() {
        face = nil
        nextEdge = nil
        oppositeEdge = nil
        previousEdge = nil
        isBucketed = false
        isTagged = false
    }
}

extension DelauneyTriangulationEdge: Equatable {
    static func == (lhs: DelauneyTriangulationEdge, rhs: DelauneyTriangulationEdge) -> Bool {
        lhs === rhs
    }
}

extension DelauneyTriangulationEdge: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

