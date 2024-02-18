//
//  DelauneyTriangulationData.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/18/24.
//

import Foundation

class DelauneyTriangulationData {
    
    let delauneyTriangulatorPartsFactory: DelauneyTriangulatorPartsFactory
    init(delauneyTriangulatorPartsFactory: DelauneyTriangulatorPartsFactory) {
        self.delauneyTriangulatorPartsFactory = delauneyTriangulatorPartsFactory
    }
    
    var vertices = Set<DelauneyTriangulationVertex>()
    var edges = Set<DelauneyTriangulationEdge>()
    var faces = Set<DelauneyTriangulationFace>()
    
    let superTrianglePoint1 = DelauneyTriangulationPoint(x: 100.0, y: -100.0)
    let superTrianglePoint2 = DelauneyTriangulationPoint(x: -100.0, y: -100.0)
    let superTrianglePoint3 = DelauneyTriangulationPoint(x: 0.0, y: 100.0)
    
    func addSuperTriangle(superTriangleSize: Float) {
        
        superTrianglePoint1.x = superTriangleSize
        superTrianglePoint1.y = -superTriangleSize
        superTrianglePoint2.x = -superTriangleSize
        superTrianglePoint2.y = -superTriangleSize
        superTrianglePoint3.x = 0.0
        superTrianglePoint3.y = superTriangleSize
        
        let vertex1 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationVertex(point: superTrianglePoint1)
        let vertex2 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationVertex(point: superTrianglePoint2)
        let vertex3 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationVertex(point: superTrianglePoint3)
        let edge1 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationEdge(vertex: vertex1)
        let edge2 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationEdge(vertex: vertex2)
        let edge3 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationEdge(vertex: vertex3)
        let face = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationFace(edge: edge1)
        
        edge1.nextEdge = edge2
        edge2.nextEdge = edge3
        edge3.nextEdge = edge1
        edge1.previousEdge = edge3
        edge2.previousEdge = edge1
        edge3.previousEdge = edge2
        vertex1.edge = edge2
        vertex2.edge = edge3
        vertex3.edge = edge1
        
        edge1.face = face
        edge2.face = face
        edge3.face = face
        
        add(edge: edge1)
        add(edge: edge2)
        add(edge: edge3)
        add(face: face)
        add(vertex: vertex1)
        add(vertex: vertex2)
        add(vertex: vertex3)
    }
    
    func add(vertex: DelauneyTriangulationVertex) {
        vertices.insert(vertex)
    }
    
    func add(edge: DelauneyTriangulationEdge) {
        edges.insert(edge)
    }
    
    func add(face: DelauneyTriangulationFace) {
        faces.insert(face)
    }
    
    func remove(vertex: DelauneyTriangulationVertex) {
        delauneyTriangulatorPartsFactory.depositDelauneyTriangulationVertex(vertex)
        vertices.remove(vertex)
    }
    
    func remove(edge: DelauneyTriangulationEdge) {
        delauneyTriangulatorPartsFactory.depositDelauneyTriangulationEdge(edge)
        edges.remove(edge)
    }
    
    func remove(face: DelauneyTriangulationFace) {
        delauneyTriangulatorPartsFactory.depositDelauneyTriangulationFace(face)
        faces.remove(face)
    }
    
    func reset() {
        for vertex in vertices {
            delauneyTriangulatorPartsFactory.depositDelauneyTriangulationVertex(vertex)
        }
        vertices.removeAll(keepingCapacity: true)
        
        for edge in edges {
            delauneyTriangulatorPartsFactory.depositDelauneyTriangulationEdge(edge)
        }
        edges.removeAll(keepingCapacity: true)
        
        for face in faces {
            delauneyTriangulatorPartsFactory.depositDelauneyTriangulationFace(face)
        }
        faces.removeAll(keepingCapacity: true)
    }
}

