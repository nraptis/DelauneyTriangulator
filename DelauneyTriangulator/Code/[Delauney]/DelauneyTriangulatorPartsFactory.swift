//
//  DelauneyTriangulatorPartsFactory.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/21/23.
//

import Foundation

class DelauneyTriangulatorPartsFactory {
    
    let DEBUG = false
    
    ////////////////
    ///
    private var triangulationPoints = [DelauneyTriangulationPoint]()
    var triangulationPointCount = 0
    var _maxDelauneyTriangulationPointCount = 0
    func depositDelauneyTriangulationPoint(_ triangulationPoint: DelauneyTriangulationPoint) {
        if DEBUG {
            for checkIndex in 0..<triangulationPointCount {
                if triangulationPoints[checkIndex] === triangulationPoint {
                    print("already exists, double deposit DelauneyTriangulationPoint @ \(checkIndex) / \(triangulationPointCount)")
                }
            }
        }
        
        while triangulationPoints.count <= triangulationPointCount {
            triangulationPoints.append(triangulationPoint)
        }
        triangulationPoints[triangulationPointCount] = triangulationPoint
        triangulationPointCount += 1
        
        if DEBUG {
            if triangulationPointCount > _maxDelauneyTriangulationPointCount {
                _maxDelauneyTriangulationPointCount = triangulationPointCount
                print("new max DelauneyTriangulationPoint: \(_maxDelauneyTriangulationPointCount)")
            }
        }
    }
    func withdrawDelauneyTriangulationPoint(x: Float, y: Float) -> DelauneyTriangulationPoint {
        if triangulationPointCount > 0 {
            triangulationPointCount -= 1
            let result = triangulationPoints[triangulationPointCount]
            result.x = x
            result.y = y
            return result
        }
        return DelauneyTriangulationPoint(x: x, y: y)
    }
    ///
    ////////////////
    
    ////////////////
    ///
    private var triangulationVertices = [DelauneyTriangulationVertex]()
    var triangulationVertexCount = 0
    var _maxDelauneyTriangulationVertexCount = 0
    func depositDelauneyTriangulationVertex(_ triangulationVertex: DelauneyTriangulationVertex) {
        if DEBUG {
            for checkIndex in 0..<triangulationVertexCount {
                if triangulationVertices[checkIndex] === triangulationVertex {
                    print("already exists, double deposit DelauneyTriangulationVertex @ \(checkIndex) / \(triangulationVertexCount)")
                }
            }
        }
        
        while triangulationVertices.count <= triangulationVertexCount {
            triangulationVertices.append(triangulationVertex)
        }
        triangulationVertices[triangulationVertexCount] = triangulationVertex
        triangulationVertexCount += 1
        
        if DEBUG {
            if triangulationVertexCount > _maxDelauneyTriangulationVertexCount {
                _maxDelauneyTriangulationVertexCount = triangulationVertexCount
                print("new max DelauneyTriangulationVertex: \(_maxDelauneyTriangulationVertexCount)")
            }
        }
    }
    func withdrawDelauneyTriangulationVertex(point: DelauneyTriangulationPoint) -> DelauneyTriangulationVertex {
        if triangulationVertexCount > 0 {
            triangulationVertexCount -= 1
            let result = triangulationVertices[triangulationVertexCount]
            result.point = point
            point.vertex = result
            return result
        }
        return DelauneyTriangulationVertex(point: point)
    }
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var triangulationEdges = [DelauneyTriangulationEdge]()
    var triangulationEdgeCount = 0
    var _maxDelauneyTriangulationEdgeCount = 0
    func depositDelauneyTriangulationEdge(_ triangulationEdge: DelauneyTriangulationEdge) {
        if DEBUG {
            for checkIndex in 0..<triangulationEdgeCount {
                if triangulationEdges[checkIndex] === triangulationEdge {
                    print("already exists, double deposit DelauneyTriangulationEdge @ \(checkIndex) / \(triangulationEdgeCount)")
                }
            }
        }
        
        triangulationEdge.clear()
        
        while triangulationEdges.count <= triangulationEdgeCount {
            triangulationEdges.append(triangulationEdge)
        }
        triangulationEdges[triangulationEdgeCount] = triangulationEdge
        triangulationEdgeCount += 1
        
        if DEBUG {
            if triangulationEdgeCount > _maxDelauneyTriangulationEdgeCount {
                _maxDelauneyTriangulationEdgeCount = triangulationEdgeCount
                print("new max DelauneyTriangulationEdge: \(_maxDelauneyTriangulationEdgeCount)")
            }
        }
    }
    func withdrawDelauneyTriangulationEdge(vertex: DelauneyTriangulationVertex) -> DelauneyTriangulationEdge {
        if triangulationEdgeCount > 0 {
            triangulationEdgeCount -= 1
            let result = triangulationEdges[triangulationEdgeCount]
            result.vertex = vertex
            return result
        }
        return DelauneyTriangulationEdge(vertex: vertex)
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var triangulationFaces = [DelauneyTriangulationFace]()
    var triangulationFaceCount = 0
    var _maxDelauneyTriangulationFaceCount = 0
    func depositDelauneyTriangulationFace(_ triangulationFace: DelauneyTriangulationFace) {
        if DEBUG {
            for checkIndex in 0..<triangulationFaceCount {
                if triangulationFaces[checkIndex] === triangulationFace {
                    print("already exists, double deposit DelauneyTriangulationFace @ \(checkIndex) / \(triangulationFaceCount)")
                }
            }
        }
        
        while triangulationFaces.count <= triangulationFaceCount {
            triangulationFaces.append(triangulationFace)
        }
        triangulationFaces[triangulationFaceCount] = triangulationFace
        triangulationFaceCount += 1
        
        if DEBUG {
            if triangulationFaceCount > _maxDelauneyTriangulationFaceCount {
                _maxDelauneyTriangulationFaceCount = triangulationFaceCount
                print("new max DelauneyTriangulationFace: \(_maxDelauneyTriangulationFaceCount)")
            }
        }
    }
    func withdrawDelauneyTriangulationFace(edge: DelauneyTriangulationEdge) -> DelauneyTriangulationFace {
        if triangulationFaceCount > 0 {
            triangulationFaceCount -= 1
            let result = triangulationFaces[triangulationFaceCount]
            result.edge = edge
            return result
        }
        return DelauneyTriangulationFace(edge: edge)
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var triangulationTriangles = [DelauneyTriangulationTriangle]()
    var triangulationTriangleCount = 0
    var _maxDelauneyTriangulationTriangleCount = 0
    func depositDelauneyTriangulationTriangle(_ triangulationTriangle: DelauneyTriangulationTriangle) {
        if DEBUG {
            for checkIndex in 0..<triangulationTriangleCount {
                if triangulationTriangles[checkIndex] === triangulationTriangle {
                    print("already exists, double deposit DelauneyTriangulationTriangle @ \(checkIndex) / \(triangulationTriangleCount)")
                }
            }
        }
        
        while triangulationTriangles.count <= triangulationTriangleCount {
            triangulationTriangles.append(triangulationTriangle)
        }
        triangulationTriangles[triangulationTriangleCount] = triangulationTriangle
        triangulationTriangleCount += 1
        
        if DEBUG {
            if triangulationTriangleCount > _maxDelauneyTriangulationTriangleCount {
                _maxDelauneyTriangulationTriangleCount = triangulationTriangleCount
                print("new max DelauneyTriangulationTriangle: \(_maxDelauneyTriangulationTriangleCount)")
            }
        }
    }
    func withdrawDelauneyTriangulationTriangle(point1: DelauneyTriangulationPoint, point2: DelauneyTriangulationPoint, point3: DelauneyTriangulationPoint) -> DelauneyTriangulationTriangle {
        if triangulationTriangleCount > 0 {
            triangulationTriangleCount -= 1
            let result = triangulationTriangles[triangulationTriangleCount]
            result.point1 = point1
            result.point2 = point2
            result.point3 = point3
            return result
        }
        return DelauneyTriangulationTriangle(point1: point1, point2: point2, point3: point3)
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var triangulationLineSegments = [DelauneyTriangulationLineSegment]()
    var triangulationLineSegmentCount = 0
    var _maxDelauneyTriangulationLineSegmentCount = 0
    func depositDelauneyTriangulationLineSegment(_ triangulationLineSegment: DelauneyTriangulationLineSegment) {
        if DEBUG {
            for checkIndex in 0..<triangulationLineSegmentCount {
                if triangulationLineSegments[checkIndex] === triangulationLineSegment {
                    print("already exists, double deposit DelauneyTriangulationLineSegment @ \(checkIndex) / \(triangulationLineSegmentCount)")
                }
            }
        }
        
        while triangulationLineSegments.count <= triangulationLineSegmentCount {
            triangulationLineSegments.append(triangulationLineSegment)
        }
        triangulationLineSegments[triangulationLineSegmentCount] = triangulationLineSegment
        triangulationLineSegmentCount += 1
        
        if DEBUG {
            if triangulationLineSegmentCount > _maxDelauneyTriangulationLineSegmentCount {
                _maxDelauneyTriangulationLineSegmentCount = triangulationLineSegmentCount
                print("new max DelauneyTriangulationLineSegment: \(_maxDelauneyTriangulationLineSegmentCount)")
            }
        }
    }
    func withdrawDelauneyTriangulationLineSegment(point1: DelauneyTriangulationPoint, point2: DelauneyTriangulationPoint) -> DelauneyTriangulationLineSegment {
        if triangulationLineSegmentCount > 0 {
            triangulationLineSegmentCount -= 1
            let result = triangulationLineSegments[triangulationLineSegmentCount]
            result.point1 = point1
            result.point2 = point2
            return result
        }
        return DelauneyTriangulationLineSegment(point1: point1, point2: point2)
    }
    ///
    ///
    ////////////////
    
}
