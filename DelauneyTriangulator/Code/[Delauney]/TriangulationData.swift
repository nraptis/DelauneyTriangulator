//
//  TriangulationData.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/12/23.
//

import Foundation

class TriangulationData {
    
    let partsFactory: DelauneyTriangulatorPartsFactory
    init(partsFactory: DelauneyTriangulatorPartsFactory) {
        self.partsFactory = partsFactory
    }
    
    var vertices = Set<TriangulationVertex>()
    var edges = Set<TriangulationEdge>()
    var faces = Set<TriangulationFace>()
    
    let superTrianglePoint1 = TriangulationPoint(x: 100.0, y: -100.0)
    let superTrianglePoint2 = TriangulationPoint(x: -100.0, y: -100.0)
    let superTrianglePoint3 = TriangulationPoint(x: 0.0, y: 100.0)
    
    func addSuperTriangle(superTriangleSize: Float) {
        
        superTrianglePoint1.x = superTriangleSize
        superTrianglePoint1.y = -superTriangleSize
        superTrianglePoint2.x = -superTriangleSize
        superTrianglePoint2.y = -superTriangleSize
        superTrianglePoint3.x = 0.0
        superTrianglePoint3.y = superTriangleSize
        
        let vertex1 = partsFactory.withdrawVertex(point: superTrianglePoint1)
        let vertex2 = partsFactory.withdrawVertex(point: superTrianglePoint2)
        let vertex3 = partsFactory.withdrawVertex(point: superTrianglePoint3)
        let edge1 = partsFactory.withdrawEdge(vertex: vertex1)
        let edge2 = partsFactory.withdrawEdge(vertex: vertex2)
        let edge3 = partsFactory.withdrawEdge(vertex: vertex3)
        let face = partsFactory.withdrawFace(edge: edge1)
        
        edge1.nextEdge = edge2; edge2.nextEdge = edge3; edge3.nextEdge = edge1
        edge1.previousEdge = edge3; edge2.previousEdge = edge1; edge3.previousEdge = edge2
        vertex1.edge = edge2; vertex2.edge = edge3; vertex3.edge = edge1
        
        edge1.face = face; edge2.face = face; edge3.face = face
        
        add(edge: edge1); add(edge: edge2); add(edge: edge3)
        add(face: face)
        add(vertex: vertex1); add(vertex: vertex2); add(vertex: vertex3)
    }
    
    func add(vertex: TriangulationVertex) {
        vertices.insert(vertex)
    }
    
    func add(edge: TriangulationEdge) {
        edges.insert(edge)
    }
    
    func add(face: TriangulationFace) {
        faces.insert(face)
    }
    
    func remove(vertex: TriangulationVertex) {
        partsFactory.depositVertex(vertex)
        vertices.remove(vertex)
    }
    
    func remove(edge: TriangulationEdge) {
        partsFactory.depositEdge(edge)
        edges.remove(edge)
    }
    
    func remove(face: TriangulationFace) {
        partsFactory.depositFace(face)
        faces.remove(face)
    }
    
    func reset() {
        for vertex in vertices {
            partsFactory.depositVertex(vertex)
        }
        vertices.removeAll(keepingCapacity: true)
        
        for edge in edges {
            partsFactory.depositEdge(edge)
        }
        edges.removeAll(keepingCapacity: true)
        
        for face in faces {
            partsFactory.depositFace(face)
        }
        faces.removeAll(keepingCapacity: true)
    }
}

class TriangulationPoint {
    var x: Float
    var y: Float
    unowned var vertex: TriangulationVertex!
    var isHullPoint = false
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

extension TriangulationPoint: Hashable {
    static func == (lhs: TriangulationPoint, rhs: TriangulationPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

class TriangulationVertex {
    var point: TriangulationPoint
    var edge: TriangulationEdge!
    
    init(point: TriangulationPoint) {
        self.point = point
        point.vertex = self
    }
    
    func clear() {
        edge = nil
    }
}

extension TriangulationVertex: Hashable {
    static func == (lhs: TriangulationVertex, rhs: TriangulationVertex) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

class TriangulationEdge {
    init(vertex: TriangulationVertex) {
        self.vertex = vertex
    }
    
    var vertex: TriangulationVertex
    var face: TriangulationFace!
    var nextEdge: TriangulationEdge!
    var oppositeEdge: TriangulationEdge!
    var previousEdge: TriangulationEdge!
    
    var isTagged = false
    
    func clear() {
        face = nil
        nextEdge = nil
        oppositeEdge = nil
        previousEdge = nil
        isTagged = false
    }
}

extension TriangulationEdge: Hashable {
    static func == (lhs: TriangulationEdge, rhs: TriangulationEdge) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

class TriangulationFace {
    var edge: TriangulationEdge
    init(edge: TriangulationEdge) {
        self.edge = edge
    }
}

extension TriangulationFace: Hashable {
    static func == (lhs: TriangulationFace, rhs: TriangulationFace) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

class TriangulationTriangle {
    var point1: TriangulationPoint
    var point2: TriangulationPoint
    var point3: TriangulationPoint
    init(point1: TriangulationPoint,
         point2: TriangulationPoint,
         point3: TriangulationPoint) {
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
    }
}

extension TriangulationTriangle: Hashable {
    static func == (lhs: TriangulationTriangle, rhs: TriangulationTriangle) -> Bool {
        lhs.point1 == rhs.point1 &&
        lhs.point2 == rhs.point2 &&
        lhs.point3 == rhs.point3
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(point1)
        hasher.combine(point2)
        hasher.combine(point3)
    }
}


class TriangulationLineSegment {
    unowned var point1: TriangulationPoint!
    unowned var point2: TriangulationPoint!
    var isTagged = false
    
    init(point1: TriangulationPoint,
         point2: TriangulationPoint) {
        self.point1 = point1
        self.point2 = point2
    }
    
    func clear() {
        point1 = nil
        point2 = nil
        isTagged = false
    }
}

extension TriangulationLineSegment: Hashable {
    static func == (lhs: TriangulationLineSegment, rhs: TriangulationLineSegment) -> Bool {
        lhs.point1 === rhs.point1
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(point1)
        hasher.combine(point2)
    }
}
