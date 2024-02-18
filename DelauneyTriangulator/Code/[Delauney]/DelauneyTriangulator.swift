//
//  DelauneyTriangulator.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/18/24.
//

import Foundation

protocol PointProtocol {
    var x: Float { set get }
    var y: Float { set get }
}

class DelauneyTriangulator {
    
    static let shared = DelauneyTriangulator()
    
    private let triangulationData: DelauneyTriangulationData
    
    private let delauneyTriangulatorPartsFactory: DelauneyTriangulatorPartsFactory
    
    private(set) var triangles: [DelauneyTriangulationTriangle]
    private(set) var triangleCount = 0
    private func trianglesAdd(triangle: DelauneyTriangulationTriangle) {
        while triangles.count <= triangleCount {
            triangles.append(triangle)
        }
        triangles[triangleCount] = triangle
        triangleCount += 1
    }
    
    private(set) var tempTriangles: [DelauneyTriangulationTriangle]
    private(set) var tempTriangleCount = 0
    
    private func tempTrianglesAdd(tempTriangle: DelauneyTriangulationTriangle) {
        while tempTriangles.count <= tempTriangleCount {
            tempTriangles.append(tempTriangle)
        }
        tempTriangles[tempTriangleCount] = tempTriangle
        tempTriangleCount += 1
    }
    
    private var edges: [DelauneyTriangulationEdge]
    private var edgeCount = 0
    private func edgesAdd(edge: DelauneyTriangulationEdge) {
        while edges.count <= edgeCount {
            edges.append(edge)
        }
        edges[edgeCount] = edge
        edgeCount += 1
    }
    
    private var faces: [DelauneyTriangulationFace]
    private var faceCount = 0
    private func facesAdd(face: DelauneyTriangulationFace) {
        while faces.count <= faceCount {
            faces.append(face)
        }
        faces[faceCount] = face
        faceCount += 1
    }
    private func facesContains(face: DelauneyTriangulationFace) -> Bool {
        for faceIndex in 0..<faceCount {
            if faces[faceIndex] === face {
                return true
            }
        }
        return false
    }
    private func facesRemove(face: DelauneyTriangulationFace) {
        for checkIndex in 0..<faceCount {
            if faces[checkIndex] === face {
                facesRemove(checkIndex)
                return
            }
        }
    }
    private func facesRemove(_ index: Int) {
        faceCount -= 1
        var faceIndex = index
        while faceIndex < faceCount {
            faces[faceIndex] = faces[faceIndex + 1]
            faceIndex += 1
        }
    }
    
    private var triangulationPoints: [DelauneyTriangulationPoint]
    private var triangulationPointCount = 0
    
    private func triangulationPointsAdd(triangulationPoint: DelauneyTriangulationPoint) {
        while triangulationPoints.count <= triangulationPointCount {
            triangulationPoints.append(triangulationPoint)
        }
        triangulationPoints[triangulationPointCount] = triangulationPoint
        triangulationPointCount += 1
    }
    
    private(set) var triangulationHullPoints: [DelauneyTriangulationPoint]
    private(set) var triangulationHullPointCount = 0
    
    private func triangulationHullPointsAdd(triangulationHullPoint: DelauneyTriangulationPoint) {
        while triangulationHullPoints.count <= triangulationHullPointCount {
            triangulationHullPoints.append(triangulationHullPoint)
        }
        triangulationHullPoints[triangulationHullPointCount] = triangulationHullPoint
        triangulationHullPointCount += 1
    }
    
    private var lineSegments: [DelauneyTriangulationLineSegment]
    private var lineSegmentCount = 0
    func lineSegmentsAdd(lineSegment: DelauneyTriangulationLineSegment) {
        while lineSegments.count <= lineSegmentCount {
            lineSegments.append(lineSegment)
        }
        lineSegments[lineSegmentCount] = lineSegment
        lineSegmentCount += 1
    }
    
    private var triangulationEdgeBucket: DelauneyTriangulationEdgeBucket
    private var triangulationPointInsidePolygonBucket: DelauneyTriangulationPointInsidePolygonBucket
    
    private let epsilon: Float
    
    private init() {
        delauneyTriangulatorPartsFactory = DelauneyTriangulatorPartsFactory()
        triangulationData = DelauneyTriangulationData(delauneyTriangulatorPartsFactory: delauneyTriangulatorPartsFactory)
        triangles = [DelauneyTriangulationTriangle]()
        tempTriangles = [DelauneyTriangulationTriangle]()
        edges = [DelauneyTriangulationEdge]()
        faces = [DelauneyTriangulationFace]()
        
        triangulationPoints = [DelauneyTriangulationPoint]()
        triangulationHullPoints = [DelauneyTriangulationPoint]()
        
        lineSegments = [DelauneyTriangulationLineSegment]()
        
        triangulationEdgeBucket = DelauneyTriangulationEdgeBucket()
        triangulationPointInsidePolygonBucket = DelauneyTriangulationPointInsidePolygonBucket()
        
        epsilon = 0.00001
    }
    
    func triangulate(points: [PointProtocol],
                     pointCount: Int,
                     hull: [PointProtocol],
                     hullCount: Int,
                     superTriangleSize: Float = 8192) {
        for triangulationPointIndex in 0..<triangulationPointCount {
            let triangulationPoint = triangulationPoints[triangulationPointIndex]
            delauneyTriangulatorPartsFactory.depositDelauneyTriangulationPoint(triangulationPoint)
        }
        triangulationPointCount = 0
        triangulationHullPointCount = 0
        
        for pointIndex in 0..<pointCount {
            let point = points[pointIndex]
            let triangulationPoint = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationPoint(x: point.x, y: point.y)
            triangulationPointsAdd(triangulationPoint: triangulationPoint)
        }
        
        for pointIndex in 0..<hullCount {
            let point = hull[pointIndex]
            let triangulationPoint = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationPoint(x: point.x, y: point.y)
            triangulationHullPointsAdd(triangulationHullPoint: triangulationPoint)
            triangulationPointsAdd(triangulationPoint: triangulationPoint)
        }
        
        if triangulateConstrained(triangulationData: triangulationData,
                                  superTriangleSize: superTriangleSize) {
            populateTriangles(triangulationData: triangulationData)
            removeTrianglesOutsideHull()
            
        } else {
            reset()
        }
    }
    
    func triangulate(points: [PointProtocol],
                     pointCount: Int,
                     superTriangleSize: Float = 8192) {
        for triangulationPointIndex in 0..<triangulationPointCount {
            let triangulationPoint = triangulationPoints[triangulationPointIndex]
            delauneyTriangulatorPartsFactory.depositDelauneyTriangulationPoint(triangulationPoint)
        }
        triangulationPointCount = 0
        triangulationHullPointCount = 0
        
        for pointIndex in 0..<pointCount {
            let point = points[pointIndex]
            let triangulationPoint = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationPoint(x: point.x, y: point.y)
            triangulationPointsAdd(triangulationPoint: triangulationPoint)
        }
        
        if triangulateBase(triangulationData: triangulationData,
                           superTriangleSize: superTriangleSize) {
            populateTriangles(triangulationData: triangulationData)
        } else {
            reset()
        }
    }
    
    private func triangulateConstrained(triangulationData: DelauneyTriangulationData,
                                        superTriangleSize: Float = 8192) -> Bool {
        if triangulateBase(triangulationData: triangulationData, superTriangleSize: superTriangleSize) {
            if constrainWithHull(triangleData: triangulationData) {
                return true
            } else {
                print("?")
            }
        }
        return false
    }
    
    private func triangulateBase(triangulationData: DelauneyTriangulationData, superTriangleSize: Float = 8192) -> Bool {
        reset()
        triangulationData.addSuperTriangle(superTriangleSize: superTriangleSize)
        for triangulationPointIndex in 0..<triangulationPointCount {
            let triangulationPoint = triangulationPoints[triangulationPointIndex]
            if !insert(point: triangulationPoint, triangulationData: triangulationData) {
                return false
            }
        }
        removeSuperTriangle(point1: triangulationData.superTrianglePoint1,
                            point2: triangulationData.superTrianglePoint2,
                            point3: triangulationData.superTrianglePoint3,
                            triangulationData: triangulationData)
        return true
    }
    
    private func reset() {
        for triangleIndex in 0..<triangleCount {
            let triangle = triangles[triangleIndex]
            delauneyTriangulatorPartsFactory.depositDelauneyTriangulationTriangle(triangle)
        }
        triangleCount = 0
        edgeCount = 0
        faceCount = 0
        triangulationData.reset()
    }
    
    private func insert(point: DelauneyTriangulationPoint, triangulationData: DelauneyTriangulationData) -> Bool {
        guard let face = walk(point: point,
                              triangulationData: triangulationData) else {
            return false
        }
        splitTriangleFace(face: face,
                          point: point,
                          triangulationData: triangulationData)
        if !insertOpposite(point: point,
                           triangulationData: triangulationData) {
            return false
        }
        
        var fudge = 0
        while edgeCount > 0 {
            fudge += 1
            if fudge > 10_000 {
                return false
            }
            
            edgeCount -= 1
            let edge = edges[edgeCount]
            
            edge.isTagged = false
            
            let point1 = edge.vertex.point
            let point2 = edge.previousEdge.vertex.point
            let point3 = edge.nextEdge.vertex.point
            
            if shouldFlipEdge(point1: point1,
                              point2: point2,
                              point3: point3,
                              target: point) {
                flip(edge: edge)
                if !insertOpposite(point: point,
                                   triangulationData: triangulationData) {
                    return false
                }
            }
        }
        return true
    }
    
    private func insertOpposite(point: DelauneyTriangulationPoint,
                                triangulationData: DelauneyTriangulationData) -> Bool {
        
        guard var pivotVertex = point.vertex else {
            return false
        }
        
        let startFace = pivotVertex.edge.face!
        var currentFace: DelauneyTriangulationFace!
        
        var fudge = 0
        while currentFace !== startFace {
            fudge += 1
            if fudge > 10_000 {
                return false
            }
            
            let oppositeEdge: DelauneyTriangulationEdge! = pivotVertex.edge.nextEdge.oppositeEdge
            if oppositeEdge !== nil && !oppositeEdge.isTagged {
                edgesAdd(edge: oppositeEdge)
                oppositeEdge.isTagged = true
            }
            pivotVertex = pivotVertex.edge.oppositeEdge.vertex
            currentFace = pivotVertex.edge.face
        }
        return true
    }
    
    private func walk(point: DelauneyTriangulationPoint, triangulationData: DelauneyTriangulationData) -> DelauneyTriangulationFace? {
        
        var result: DelauneyTriangulationFace?
        if triangulationData.faces.count <= 0 {
            return result
        }
        
        var triangle: DelauneyTriangulationFace! = triangulationData.faces.first
        var fudge = 0
        while true {
            fudge += 1
            if fudge > 10_000 {
                return nil
            }
            
            let edge1 = triangle.edge
            let edge2 = edge1.nextEdge!
            let edge3 = edge2.nextEdge!
            if right(linePoint1: edge1.previousEdge.vertex.point,
                     linePoint2: edge1.vertex.point,
                     point: point) {
                if right(linePoint1: edge2.previousEdge.vertex.point,
                         linePoint2: edge2.vertex.point,
                         point: point) {
                    if right(linePoint1: edge3.previousEdge.vertex.point,
                             linePoint2: edge3.vertex.point,
                             point: point) {
                        result = triangle
                        break
                    } else {
                        triangle = edge3.oppositeEdge.face
                    }
                } else {
                    triangle = edge2.oppositeEdge.face
                }
            } else {
                triangle = edge1.oppositeEdge.face
            }
        }
        return result
    }
    
    private func right(linePoint1: DelauneyTriangulationPoint,
                       linePoint2: DelauneyTriangulationPoint,
                       point: DelauneyTriangulationPoint) -> Bool {
        let line1DeltaX = linePoint1.x - point.x
        let line1DeltaY = linePoint1.y - point.y
        let line2DeltaX = linePoint2.x - point.x
        let line2DeltaY = linePoint2.y - point.y
        if cross(x1: line1DeltaX,
                 y1: line2DeltaX,
                 x2: line1DeltaY,
                 y2: line2DeltaY) < epsilon {
            return true
        } else {
            return false
        }
    }
    
    private func shouldFlipEdge(point1: DelauneyTriangulationPoint,
                                point2: DelauneyTriangulationPoint,
                                point3: DelauneyTriangulationPoint,
                                target: DelauneyTriangulationPoint) -> Bool {
        let factorA13 = point1.x - point3.x
        let factorA23 = point2.x - point3.x
        let factorA1T = point1.x - target.x
        let factorA2T = point2.x - target.x
        let factorB13 = point1.y - point3.y
        let factorB23 = point2.y - point3.y
        let factorB1T = point1.y - target.y
        let factorB2T = point2.y - target.y
        let cosA = factorA13 * factorA23 + factorB13 * factorB23
        let cosB = factorA2T * factorA1T + factorB2T * factorB1T
        
        if cosA >= 0.0 && cosB >= 0.0 { return false }
        if cosA < 0.0 && cosB < 0.0 { return true }
        
        let sinABLHS = (factorA13 * factorB23 - factorA23 * factorB13) * cosB
        let sinABRHS = (factorA2T * factorB1T - factorA1T * factorB2T) * cosA
        
        if (sinABLHS + sinABRHS) < 0.0 {
            return true
        } else {
            return false
        }
    }
    
    private func flip(edge: DelauneyTriangulationEdge) {
        let edge1 = edge; let edge2 = edge1.nextEdge!
        let edge3 = edge1.previousEdge!; let edge4 = edge1.oppositeEdge!
        let edge5 = edge4.nextEdge!; let edge6 = edge4.previousEdge!
        
        let vertexA = edge1.vertex; let vertexB = edge1.nextEdge.vertex
        let vertexC = edge1.previousEdge.vertex; let vertexD = edge4.nextEdge.vertex
        
        let pointB = edge2.vertex.point
        let pointD = edge5.vertex.point
        let oppositeVertexA = edge4.previousEdge.vertex
        let oppositeVertexC = edge4.vertex
        
        let oppositeVertexB = oppositeVertexA
        oppositeVertexB.point = pointB
        pointB.vertex = oppositeVertexB
        
        let oppositeVertexD = oppositeVertexC
        oppositeVertexD.point = pointD
        pointD.vertex = oppositeVertexD
        
        edge1.nextEdge = edge3; edge1.previousEdge = edge5
        edge2.nextEdge = edge4; edge2.previousEdge = edge6
        edge3.nextEdge = edge5; edge3.previousEdge = edge1
        edge4.nextEdge = edge6; edge4.previousEdge = edge2
        edge5.nextEdge = edge1; edge5.previousEdge = edge3
        edge6.nextEdge = edge2; edge6.previousEdge = edge4
        
        edge1.vertex = vertexB; edge2.vertex = oppositeVertexB
        edge3.vertex = vertexC; edge4.vertex = oppositeVertexD
        edge5.vertex = vertexD; edge6.vertex = vertexA
        
        let face1 = edge1.face!; let face2 = edge4.face!
        edge1.face = face1; edge2.face = face2
        edge3.face = face1; edge4.face = face2
        edge5.face = face1; edge6.face = face2
        
        face1.edge = edge3; face2.edge = edge4
        
        vertexA.edge = edge2; vertexB.edge = edge3
        vertexC.edge = edge5; vertexD.edge = edge1
        oppositeVertexB.edge = edge4; oppositeVertexD.edge = edge6
    }
    
    private func flipWithBucket(edge: DelauneyTriangulationEdge) {
        let edge1 = edge; let edge2 = edge1.nextEdge!
        let edge3 = edge1.previousEdge!; let edge4 = edge1.oppositeEdge!
        let edge5 = edge4.nextEdge!; let edge6 = edge4.previousEdge!
        
        triangulationEdgeBucket.remove(triangulationEdge: edge1); triangulationEdgeBucket.remove(triangulationEdge: edge2)
        triangulationEdgeBucket.remove(triangulationEdge: edge3); triangulationEdgeBucket.remove(triangulationEdge: edge4)
        triangulationEdgeBucket.remove(triangulationEdge: edge5); triangulationEdgeBucket.remove(triangulationEdge: edge6)
        
        let vertexA = edge1.vertex; let vertexB = edge1.nextEdge.vertex
        let vertexC = edge1.previousEdge.vertex; let vertexD = edge4.nextEdge.vertex
        
        let pointB = edge2.vertex.point
        let pointD = edge5.vertex.point
        let oppositeVertexA = edge4.previousEdge.vertex
        let oppositeVertexC = edge4.vertex
        
        let oppositeVertexB = oppositeVertexA
        oppositeVertexB.point = pointB
        pointB.vertex = oppositeVertexB
        
        let oppositeVertexD = oppositeVertexC
        oppositeVertexD.point = pointD
        pointD.vertex = oppositeVertexD
        
        edge1.nextEdge = edge3; edge1.previousEdge = edge5
        edge2.nextEdge = edge4; edge2.previousEdge = edge6
        edge3.nextEdge = edge5; edge3.previousEdge = edge1
        edge4.nextEdge = edge6; edge4.previousEdge = edge2
        edge5.nextEdge = edge1; edge5.previousEdge = edge3
        edge6.nextEdge = edge2; edge6.previousEdge = edge4
        
        edge1.vertex = vertexB; edge2.vertex = oppositeVertexB
        edge3.vertex = vertexC; edge4.vertex = oppositeVertexD
        edge5.vertex = vertexD; edge6.vertex = vertexA
        
        let face1 = edge1.face!; let face2 = edge4.face!
        edge1.face = face1; edge2.face = face2
        edge3.face = face1; edge4.face = face2
        edge5.face = face1; edge6.face = face2
        
        face1.edge = edge3; face2.edge = edge4
        
        vertexA.edge = edge2; vertexB.edge = edge3
        vertexC.edge = edge5; vertexD.edge = edge1
        oppositeVertexB.edge = edge4; oppositeVertexD.edge = edge6
        
        triangulationEdgeBucket.add(triangulationEdge: edge1); triangulationEdgeBucket.add(triangulationEdge: edge2)
        triangulationEdgeBucket.add(triangulationEdge: edge3); triangulationEdgeBucket.add(triangulationEdge: edge4)
        triangulationEdgeBucket.add(triangulationEdge: edge5); triangulationEdgeBucket.add(triangulationEdge: edge6)
    }
    
    private func removeIntersectingEdges(point1: DelauneyTriangulationPoint,
                                         point2: DelauneyTriangulationPoint) -> Bool {
        var fudge = 0
        while edgeCount > 0 {
            
            fudge += 1
            if fudge > 1_000 {
                return false
            }
            
            
            let edge = edges[0]
            
            edgeCount -= 1
            var edgeIndex = 0
            while edgeIndex < edgeCount {
                edges[edgeIndex] = edges[edgeIndex + 1]
                edgeIndex += 1
            }
            
            if edge.oppositeEdge === nil {
                return false
            }
            
            let trianglePoint1 = edge.vertex.point
            let trianglePoint2 = edge.previousEdge.vertex.point
            let trianglePoint3 = edge.nextEdge.vertex.point
            let oppositePoint1 = edge.oppositeEdge.nextEdge.vertex.point
            if !quadIsConvex(point1: trianglePoint1,
                             point2: trianglePoint2,
                             point3: trianglePoint3,
                             point4: oppositePoint1) {
                edgesAdd(edge: edge)
                continue
            } else {
                flipWithBucket(edge: edge)
                if edgesCross(edge1Point1: point1,
                              edge1Point2: point2,
                              edge2Point1: edge.vertex.point,
                              edge2Point2: edge.previousEdge.vertex.point) {
                    edgesAdd(edge: edge)
                }
            }
        }
        return true
    }
    
    private func edgesCross(edge1Point1: DelauneyTriangulationPoint,
                    edge1Point2: DelauneyTriangulationPoint,
                    edge2Point1: DelauneyTriangulationPoint,
                    edge2Point2: DelauneyTriangulationPoint) -> Bool {
        if edge1Point1 == edge2Point1 || edge1Point1 == edge2Point2 || edge1Point2 == edge2Point1 || edge1Point2 == edge2Point2 {
            return false
        }
        if lineSegmentIntersectsLineSegment(line1Point1: edge1Point1,
                                            line1Point2: edge1Point2,
                                            line2Point1: edge2Point1,
                                            line2Point2: edge2Point2) {
            return true
        } else {
            return false
        }
    }
    
    private func constrainWithHull(triangleData: DelauneyTriangulationData) -> Bool {
        if triangulationHullPointCount < 3 {
            return true
        }
        
        triangulationEdgeBucket.build(triangulationEdges: triangulationData.edges)
        
        var index1 = triangulationHullPointCount - 1
        var index2 = 0
        while index2 < triangulationHullPointCount {
            let hullPoint1 = triangulationHullPoints[index1]
            let hullPoint2 = triangulationHullPoints[index2]
            
            findIntersectingEdges(triangleData: triangleData,
                                  hullPoint1: hullPoint1,
                                  hullPoint2: hullPoint2)
            if !removeIntersectingEdges(point1: hullPoint1,
                                        point2: hullPoint2) {
                return false
            }
            
            index1 = index2
            index2 += 1
        }
        
        return true
    }
    
    private func findIntersectingEdges(triangleData: DelauneyTriangulationData,
                               hullPoint1: DelauneyTriangulationPoint,
                               hullPoint2: DelauneyTriangulationPoint) {
        
        triangulationEdgeBucket.query(point1: hullPoint1,
                                      point2: hullPoint2)
        
        for triangulationEdgeIndex in 0..<triangulationEdgeBucket.triangulationEdgeCount {
            let triangulationEdge = triangulationEdgeBucket.triangulationEdges[triangulationEdgeIndex]
            
            let edge1Point2 = triangulationEdge.vertex.point
            let edge1Point1 = triangulationEdge.previousEdge.vertex.point
            
            var inverseExists = false
            
            for edgeIndex in 0..<edgeCount {
                let existingEdge = edges[edgeIndex]
                let edge2Point1 = existingEdge.vertex.point
                let edge2Point2 = existingEdge.previousEdge.vertex.point
                if edge1Point1 == edge2Point1 && edge1Point2 == edge2Point2 {
                    inverseExists = true
                    break
                }
            }
            
            if inverseExists {
                continue
            }
            
            if edgesCross(edge1Point1: edge1Point1,
                          edge1Point2: edge1Point2,
                          edge2Point1: hullPoint1,
                          edge2Point2: hullPoint2) {
                edgesAdd(edge: triangulationEdge)
            }
        }
    }
    
    private func removeSuperTriangle(point1: DelauneyTriangulationPoint,
                             point2: DelauneyTriangulationPoint,
                             point3: DelauneyTriangulationPoint,
                             triangulationData: DelauneyTriangulationData) {
        faceCount = 0
        for vertex in triangulationData.vertices {
            if facesContains(face: vertex.edge.face) {
                continue
            }
            
            let vertexPoint = vertex.point
            if vertexPoint == point1 || vertexPoint == point2 || vertexPoint == point3 {
                facesAdd(face: vertex.edge.face)
            }
        }
        
        for faceIndex in 0..<faceCount {
            let face = faces[faceIndex]
            removeFaceAndClearOpposites(face: face,
                                        triangulationData: triangulationData)
        }
    }
    
    private func splitTriangleFace(face: DelauneyTriangulationFace, point: DelauneyTriangulationPoint, triangulationData: DelauneyTriangulationData) {
        
        let edge1 = face.edge
        let edge2 = edge1.nextEdge!
        let edge3 = edge2.nextEdge!
        
        createFace(edge: edge1,
                   point: point,
                   triangulationData: triangulationData)
        createFace(edge: edge2,
                   point: point,
                   triangulationData: triangulationData)
        createFace(edge: edge3,
                   point: point,
                   triangulationData: triangulationData)
        
        for edgeIndex in 0..<edgeCount {
        
            let edge = edges[edgeIndex]
            
            if edge.oppositeEdge !== nil {
                continue
            }
            
            let pointA = edge.vertex.point
            let pointB = edge.previousEdge.vertex.point
            
            for oppositeEdgeIndex in 0..<edgeCount {
                let oppositeEdge = edges[oppositeEdgeIndex]
                
                if edge === oppositeEdge {
                    continue
                }
                if oppositeEdge.oppositeEdge !== nil {
                    continue
                }
                
                if pointA == oppositeEdge.previousEdge.vertex.point && pointB == oppositeEdge.vertex.point {
                    edge.oppositeEdge = oppositeEdge
                    oppositeEdge.oppositeEdge = edge
                }
            }
        }
        edgeCount = 0
        removeFace(face: face, triangulationData: triangulationData)
    }
    
    private func createFace(edge: DelauneyTriangulationEdge, point: DelauneyTriangulationPoint, triangulationData: DelauneyTriangulationData) {
        
        let point1 = point
        let point2 = edge.previousEdge.vertex.point
        let point3 = edge.vertex.point
        
        let vertex1 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationVertex(point: point1)
        let vertex2 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationVertex(point: point2)
        let vertex3 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationVertex(point: point3)
        
        let edge1 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationEdge(vertex: vertex3)
        let edge2 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationEdge(vertex: vertex1)
        let edge3 = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationEdge(vertex: vertex2)
        
        let face = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationFace(edge: edge1)
        
        edge1.oppositeEdge = edge.oppositeEdge
        if edge1.oppositeEdge !== nil {
            edge.oppositeEdge.oppositeEdge = edge1
        }
        
        edgesAdd(edge: edge2)
        edgesAdd(edge: edge3)
        
        edge1.nextEdge = edge2; edge1.previousEdge = edge3
        edge2.nextEdge = edge3; edge2.previousEdge = edge1
        edge3.nextEdge = edge1; edge3.previousEdge = edge2
        
        edge1.face = face; edge2.face = face; edge3.face = face
        vertex1.edge = edge3; vertex2.edge = edge1; vertex3.edge = edge2
        
        triangulationData.add(face: face)
        
        triangulationData.add(edge: edge1)
        triangulationData.add(edge: edge2)
        triangulationData.add(edge: edge3)
        
        triangulationData.add(vertex: vertex1)
        triangulationData.add(vertex: vertex2)
        triangulationData.add(vertex: vertex3)
    }
    
    private func removeFace(face: DelauneyTriangulationFace, triangulationData: DelauneyTriangulationData) {
        
        let edge1 = face.edge
        let edge2 = edge1.nextEdge!
        let edge3 = edge2.nextEdge!
        
        triangulationData.remove(face: face)
        triangulationData.remove(edge: edge1)
        triangulationData.remove(edge: edge2)
        triangulationData.remove(edge: edge3)
        triangulationData.remove(vertex: edge1.vertex)
        triangulationData.remove(vertex: edge2.vertex)
        triangulationData.remove(vertex: edge3.vertex)
    }
    
    private func removeFaceAndClearOpposites(face: DelauneyTriangulationFace, triangulationData: DelauneyTriangulationData) {
        
        let edge1 = face.edge
        let edge2 = edge1.nextEdge!
        let edge3 = edge2.nextEdge!
        
        if edge1.oppositeEdge !== nil {
            edge1.oppositeEdge.oppositeEdge = nil
        }
        if edge2.oppositeEdge !== nil {
            edge2.oppositeEdge.oppositeEdge = nil
        }
        if edge3.oppositeEdge !== nil {
            edge3.oppositeEdge.oppositeEdge = nil
        }
        
        triangulationData.remove(face: face)
        
        triangulationData.remove(edge: edge1)
        triangulationData.remove(edge: edge2)
        triangulationData.remove(edge: edge3)
        
        triangulationData.remove(vertex: edge1.vertex)
        triangulationData.remove(vertex: edge2.vertex)
        triangulationData.remove(vertex: edge3.vertex)
    }
    
    private func triangleIsClockwise(point1: DelauneyTriangulationPoint,
                                     point2: DelauneyTriangulationPoint,
                                     point3: DelauneyTriangulationPoint) -> Bool {
        if (point1.x * point2.y + point3.x * point1.y + point2.x * point3.y - point1.x * point3.y - point3.x * point2.y - point2.x * point1.y) > 0.0 {
            return false
        } else {
            return true
        }
    }
    
    private func quadIsConvex(point1: DelauneyTriangulationPoint,
                              point2: DelauneyTriangulationPoint,
                              point3: DelauneyTriangulationPoint,
                              point4: DelauneyTriangulationPoint) -> Bool {
        let clockwiseA = triangleIsClockwise(point1: point1, point2: point2, point3: point3)
        let clockwiseB = triangleIsClockwise(point1: point1, point2: point2, point3: point4)
        let clockwiseC = triangleIsClockwise(point1: point2, point2: point3, point3: point4)
        let clockwiseD = triangleIsClockwise(point1: point3, point2: point1, point3: point4)
        if clockwiseA && clockwiseB && clockwiseC && !clockwiseD {
            return true
        } else if clockwiseA && clockwiseB && !clockwiseC && clockwiseD {
            return true
        } else if clockwiseA && !clockwiseB && clockwiseC && clockwiseD {
            return true
        } else if !clockwiseA && !clockwiseB && !clockwiseC && clockwiseD {
            return true
        } else if !clockwiseA && !clockwiseB && clockwiseC && !clockwiseD {
            return true
        } else if !clockwiseA && clockwiseB && !clockwiseC && !clockwiseD {
            return true
        } else {
            return false
        }
    }

    private func lineSegmentIntersectsLineSegment(line1Point1: DelauneyTriangulationPoint,
                                                  line1Point2: DelauneyTriangulationPoint,
                                                  line2Point1: DelauneyTriangulationPoint,
                                                  line2Point2: DelauneyTriangulationPoint) -> Bool {
        Math.lineSegmentIntersectsLineSegment(line1Point1X: line1Point1.x,
                                              line1Point1Y: line1Point1.y,
                                              line1Point2X: line1Point2.x,
                                              line1Point2Y: line1Point2.y,
                                              line2Point1X: line2Point1.x,
                                              line2Point1Y: line2Point1.y,
                                              line2Point2X: line2Point2.x,
                                              line2Point2Y: line2Point2.y)
    }
    
    private func cross(x1: Float, y1: Float, x2: Float, y2: Float) -> Float {
        x1 * y2 - x2 * y1
    }
    
    private func populateTriangles(triangulationData: DelauneyTriangulationData) {
        for face in triangulationData.faces {
            let point1 = face.edge.vertex.point
            let point2 = face.edge.nextEdge.vertex.point
            let point3 = face.edge.nextEdge.nextEdge.vertex.point
            let triangle = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationTriangle(point1: point1,
                                                                                          point2: point2,
                                                                                          point3: point3)
            trianglesAdd(triangle: triangle)
        }
    }
    
    private func removeTrianglesOutsideHull() {
        
        if triangulationHullPointCount < 3 {
            return
        }
        
        tempTriangleCount = 0
        for triangleIndex in 0..<triangleCount {
            let triangle = triangles[triangleIndex]
            tempTrianglesAdd(tempTriangle: triangle)
        }
        
        var index1 = triangulationHullPointCount - 1
        var index2 = 0
        while index2 < triangulationHullPointCount {
            let point1 = triangulationHullPoints[index1]
            let point2 = triangulationHullPoints[index2]
            let lineSegment = delauneyTriangulatorPartsFactory.withdrawDelauneyTriangulationLineSegment(point1: point1, point2: point2)
            lineSegmentsAdd(lineSegment: lineSegment)
            index1 = index2
            index2 += 1
        }
        
        triangulationPointInsidePolygonBucket.build(triangulationLineSegments: lineSegments,
                                                    triangulationLineSegmentCount: lineSegmentCount)
        
        triangleCount = 0
        for tempTriangleIndex in 0..<tempTriangleCount {
            let triangle = tempTriangles[tempTriangleIndex]
            let centerX = (triangle.point1.x + triangle.point2.x + triangle.point3.x) / 3.0
            let centerY = (triangle.point1.y + triangle.point2.y + triangle.point3.y) / 3.0
            if triangulationPointInsidePolygonBucket.query(x: centerX, y: centerY) {
                trianglesAdd(triangle: triangle)
            } else {
                delauneyTriangulatorPartsFactory.depositDelauneyTriangulationTriangle(triangle)
            }
        }
        
        for lineSegmentIndex in 0..<lineSegmentCount {
            let lineSegment = lineSegments[lineSegmentIndex]
            delauneyTriangulatorPartsFactory.depositDelauneyTriangulationLineSegment(lineSegment)
        }
        lineSegmentCount = 0
    }
}
