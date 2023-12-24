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
    ///
    private var triangulationPoints = [TriangulationPoint]()
    var _maxTriangulationPointCount = 0
    func depositPoint(_ triangulationPoint: TriangulationPoint) {
        if DEBUG {
            for check in triangulationPoints {
                if check === triangulationPoint {
                    print("already exists, double deposit triangulationPoint")
                }
            }
        }
        
        triangulationPoints.append(triangulationPoint)
        
        if DEBUG {
            if triangulationPoints.count > _maxTriangulationPointCount {
                _maxTriangulationPointCount = triangulationPoints.count
                print("new max triangulation points: \(_maxTriangulationPointCount)")
            }
        }
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
    var _maxTriangulationVertexCount = 0
    func depositVertex(_ triangulationVertex: TriangulationVertex) {
        if DEBUG {
            for check in triangulationVertices {
                if check === triangulationVertex {
                    print("already exists, double deposit triangulationVertex")
                }
            }
        }
        
        triangulationVertex.clear()
        triangulationVertices.append(triangulationVertex)
        
        if DEBUG {
            if triangulationVertices.count > _maxTriangulationVertexCount {
                _maxTriangulationVertexCount = triangulationVertices.count
                print("new max triangulation vertices: \(_maxTriangulationVertexCount)")
            }
        }
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
    var _maxTriangulationEdgeCount = 0
    func depositEdge(_ triangulationEdge: TriangulationEdge) {
        if DEBUG {
            for check in triangulationEdges {
                if check === triangulationEdge {
                    print("already exists, double deposit triangulationEdge")
                }
            }
        }
        
        triangulationEdge.clear()
        triangulationEdges.append(triangulationEdge)
        
        if DEBUG {
            if triangulationEdges.count > _maxTriangulationEdgeCount {
                _maxTriangulationEdgeCount = triangulationEdges.count
                print("new max triangulation Edges: \(_maxTriangulationEdgeCount)")
            }
        }
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
    var _maxTriangulationFaceCount = 0
    func depositFace(_ triangulationFace: TriangulationFace) {
        if DEBUG {
            for check in triangulationFaces {
                if check === triangulationFace {
                    print("already exists, double deposit triangulationFace")
                }
            }
        }
        
        triangulationFaces.append(triangulationFace)
        
        if DEBUG {
            if triangulationFaces.count > _maxTriangulationFaceCount {
                _maxTriangulationFaceCount = triangulationFaces.count
                print("new max triangulation faces: \(_maxTriangulationFaceCount)")
            }
        }
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
    var _maxTriangulationTriangleCount = 0
    func depositTriangle(_ triangulationTriangle: TriangulationTriangle) {
        if DEBUG {
            for check in triangulationTriangles {
                if check === triangulationTriangle {
                    print("already exists, double deposit TriangulationTriangle")
                }
            }
        }
        
        triangulationTriangles.append(triangulationTriangle)
        
        if DEBUG {
            if triangulationTriangles.count > _maxTriangulationTriangleCount {
                _maxTriangulationTriangleCount = triangulationTriangles.count
                print("new max triangulation triangles: \(_maxTriangulationTriangleCount)")
            }
        }
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
    var _maxTriangulationLineSegmentCount = 0
    func depositLineSegment(_ triangulationLineSegment: TriangulationLineSegment) {
        if DEBUG {
            for check in triangulationLineSegments {
                if check === triangulationLineSegment {
                    print("already exists, double deposit triangulationLineSegment")
                }
            }
        }
        
        triangulationLineSegments.append(triangulationLineSegment)
        triangulationLineSegment.clear()
        
        if DEBUG {
            if triangulationLineSegments.count > _maxTriangulationLineSegmentCount {
                _maxTriangulationLineSegmentCount = triangulationLineSegments.count
                print("new max triangulation line segments: \(_maxTriangulationLineSegmentCount)")
            }
        }
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
