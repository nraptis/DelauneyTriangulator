//
//  DelauneyTriangulatorPartsFactory.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/21/23.
//

import Foundation

class DelauneyTriangulatorPartsFactory {
    
    ////////////////
    ///
    ///
    private var triangulationPoints = [TriangulationPoint]()
    func depositPoint(_ point: TriangulationPoint) {
        triangulationPoints.append(point)
    }
    func withdrawPoint(x: Float, y: Float) -> TriangulationPoint {
        if triangulationPoints.count > 0 {
            let result = triangulationPoints[triangulationPoints.count - 1]
            triangulationPoints.removeLast()
            result.x = x
            result.y = y
            return result
        }
        return TriangulationPoint(x: x, y: y)
    }
    ///
    ///
    ////////////////
    
    ////////////////
    ///
    ///
    private var triangulationVertices = [TriangulationVertex]()
    func depositVertex(_ vertex: TriangulationVertex) {
        vertex.clear()
        triangulationVertices.append(vertex)
    }
    func withdrawVertex(point: TriangulationPoint) -> TriangulationVertex {
        if triangulationVertices.count > 0 {
            let result = triangulationVertices[triangulationVertices.count - 1]
            triangulationVertices.removeLast()
            result.point = point
            point.vertex = result
            return result
        }
        return TriangulationVertex(point: point)
    }
    ///
    ///
    ////////////////
    ///
    
    ////////////////
    ///
    ///
    private var triangulationEdges = [TriangulationEdge]()
    func depositEdge(_ edge: TriangulationEdge) {
        edge.clear()
        triangulationEdges.append(edge)
    }
    func withdrawEdge(vertex: TriangulationVertex) -> TriangulationEdge {
        if triangulationEdges.count > 0 {
            let result = triangulationEdges[triangulationEdges.count - 1]
            triangulationEdges.removeLast()
            result.vertex = vertex
            return result
        }
        return TriangulationEdge(vertex: vertex)
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var triangulationFaces = [TriangulationFace]()
    func depositFace(_ face: TriangulationFace) {
        triangulationFaces.append(face)
    }
    func withdrawFace(edge: TriangulationEdge) -> TriangulationFace {
        if triangulationFaces.count > 0 {
            let result = triangulationFaces[triangulationFaces.count - 1]
            triangulationFaces.removeLast()
            result.edge = edge
            return result
        }
        return TriangulationFace(edge: edge)
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
        ///
        ///
    private var triangulationTriangles = [TriangulationTriangle]()
    func depositTriangle(_ triangle: TriangulationTriangle) {
        triangulationTriangles.append(triangle)
    }
    func withdrawTriangle(point1: TriangulationPoint,
                          point2: TriangulationPoint,
                          point3: TriangulationPoint) -> TriangulationTriangle {
        if triangulationTriangles.count > 0 {
            let result = triangulationTriangles[triangulationTriangles.count - 1]
            triangulationTriangles.removeLast()
            result.point1 = point1
            result.point2 = point2
            result.point3 = point3
            return result
        }
        return TriangulationTriangle(point1: point1,
                                     point2: point2,
                                     point3: point3)
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var triangulationLineSegments = [TriangulationLineSegment]()
    func depositLineSegment(_ lineSegment: TriangulationLineSegment) {
        triangulationLineSegments.append(lineSegment)
        lineSegment.clear()
    }
    func withdrawLineSegment(point1: TriangulationPoint,
                             point2: TriangulationPoint) -> TriangulationLineSegment {
        if triangulationLineSegments.count > 0 {
            let result = triangulationLineSegments[triangulationLineSegments.count - 1]
            triangulationLineSegments.removeLast()
            result.point1 = point1
            result.point2 = point2
            return result
        }
        return TriangulationLineSegment(point1: point1,
                                        point2: point2)
    }
    ///
    ///
    ////////////////
    
}
