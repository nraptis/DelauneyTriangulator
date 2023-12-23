//
//  DelauneyTriangulator.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/21/23.
//

import Foundation

class DelauneyTriangulator {
    
    static let shared = DelauneyTriangulator()
    
    private let partsFactory: DelauneyTriangulatorPartsFactory
    private let triangulationData: TriangulationData
    private(set) var triangles: [TriangulationTriangle]
    private var edgeStack: [TriangulationEdge]
    private var faceSet: Set<TriangulationFace>
    private var edgeGridBucket: EdgeGridBucket
    private let epsilon: Float
    
    private init() {
        partsFactory = DelauneyTriangulatorPartsFactory()
        triangulationData = TriangulationData(partsFactory: partsFactory)
        triangles = [TriangulationTriangle]()
        edgeStack = [TriangulationEdge]()
        faceSet = Set<TriangulationFace>()
        edgeGridBucket = EdgeGridBucket()
        epsilon = 0.00001
    }
    
    func delauneyConstrainedTriangulation(points: [TriangulationPoint],
                                          hull: [TriangulationPoint],
                                          superTriangleSize: Float = 8192) {
        if delauneyConstrainedTriangulation(points: points,
                                            hull: hull,
                                            triangulationData: triangulationData,
                                            superTriangleSize: superTriangleSize) {
            populateTriangles(triangulationData: triangulationData)
        } else {
            reset()
        }
    }
    
    private func delauneyTriangulation(points: [TriangulationPoint],
                                       superTriangleSize: Float = 8192) {
        if delauneyTriangulation(points: points,
                                 triangulationData: triangulationData,
                                 superTriangleSize: superTriangleSize) {
            populateTriangles(triangulationData: triangulationData)
        } else {
            reset()
        }
    }
    
    private func delauneyConstrainedTriangulation(points: [TriangulationPoint],
                                                  hull: [TriangulationPoint],
                                                  triangulationData: TriangulationData,
                                                  superTriangleSize: Float = 8192) -> Bool {
        if delauneyTriangulation(points: points,
                                 triangulationData: triangulationData,
                                 superTriangleSize: superTriangleSize) {
            if constrainWithHull(triangleData: triangulationData,
                       hull: hull) {
                return true
            }
        }
        return false
    }
    
    private func delauneyTriangulation(points: [TriangulationPoint],
                                       triangulationData: TriangulationData,
                                       superTriangleSize: Float = 8192) -> Bool {
        
        reset()
        
        triangulationData.addSuperTriangle(superTriangleSize: superTriangleSize)
        
        for point in points {
            if !insert(point: point, triangulationData: triangulationData) {
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
        for triangle in triangles {
            partsFactory.depositTriangle(triangle)
        }
        triangles.removeAll(keepingCapacity: true)
        edgeStack.removeAll(keepingCapacity: true)
        faceSet.removeAll(keepingCapacity: true)
        triangulationData.reset()
    }
    
    func populateTriangles(triangulationData: TriangulationData) {
        for face in triangulationData.faces {
            let point1 = face.edge.vertex.point
            let point2 = face.edge.nextEdge.vertex.point
            let point3 = face.edge.nextEdge.nextEdge.vertex.point
            let triangle = partsFactory.withdrawTriangle(point1: point1,
                                                         point2: point2,
                                                         point3: point3)
            triangles.append(triangle)
        }
    }
    
    func insert(point: TriangulationPoint, triangulationData: TriangulationData) -> Bool {
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
        while edgeStack.count > 0 {
            fudge += 1
            if fudge > 10_000 {
                return false
            }
            
            let edge = edgeStack.removeLast()
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
    
    func insertOpposite(point: TriangulationPoint,
                        triangulationData: TriangulationData) -> Bool {
        
        guard var pivotVertex = point.vertex else {
            return false
        }
        
        let startFace = pivotVertex.edge.face!
        var currentFace: TriangulationFace!
        
        var fudge = 0
        while currentFace !== startFace {
            fudge += 1
            if fudge > 10_000 {
                return false
            }
            
            let oppositeEdge: TriangulationEdge! = pivotVertex.edge.nextEdge.oppositeEdge
            if oppositeEdge !== nil && !oppositeEdge.isTagged {
                edgeStack.append(oppositeEdge)
                oppositeEdge.isTagged = true
            }
            pivotVertex = pivotVertex.edge.oppositeEdge.vertex
            currentFace = pivotVertex.edge.face
        }
        return true
    }
    
    func walk(point: TriangulationPoint, triangulationData: TriangulationData) -> TriangulationFace? {
        
        var result: TriangulationFace?
        if triangulationData.faces.count <= 0 {
            return result
        }
        
        var triangle: TriangulationFace! = triangulationData.faces.first
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
    
    func right(linePoint1: TriangulationPoint,
               linePoint2: TriangulationPoint,
               point: TriangulationPoint) -> Bool {
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
    
    func shouldFlipEdge(point1: TriangulationPoint,
                        point2: TriangulationPoint,
                        point3: TriangulationPoint,
                        target: TriangulationPoint) -> Bool {
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

        if cosA >= 0.0 && cosB >= 0.0 {
            return false
        }
        
        if cosA < 0.0 && cosB < 0.0 {
            return true
        }

        let sinABLHS = (factorA13 * factorB23 - factorA23 * factorB13) * cosB
        let sinABRHS = (factorA2T * factorB1T - factorA1T * factorB2T) * cosA
        
        if (sinABLHS + sinABRHS) < 0.0 {
            return true
        } else {
            return false
        }
    }
    
    func flip(edge: TriangulationEdge) {
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
    
    func flipWithBucket(edge: TriangulationEdge) {
        let edge1 = edge; let edge2 = edge1.nextEdge!
        let edge3 = edge1.previousEdge!; let edge4 = edge1.oppositeEdge!
        let edge5 = edge4.nextEdge!; let edge6 = edge4.previousEdge!
        
        edgeGridBucket.remove(edge: edge1); edgeGridBucket.remove(edge: edge2)
        edgeGridBucket.remove(edge: edge3); edgeGridBucket.remove(edge: edge4)
        edgeGridBucket.remove(edge: edge5); edgeGridBucket.remove(edge: edge6)
        
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
        
        edgeGridBucket.add(edge: edge1); edgeGridBucket.add(edge: edge2)
        edgeGridBucket.add(edge: edge3); edgeGridBucket.add(edge: edge4)
        edgeGridBucket.add(edge: edge5); edgeGridBucket.add(edge: edge6)
    }
    
    func removeIntersectingEdges(point1: TriangulationPoint,
                                 point2: TriangulationPoint) -> Bool {
        var fudge = 0
        while edgeStack.count > 0 {
            
            fudge += 1
            if fudge > 1_000 {
                return false
            }

            let edge = edgeStack.removeFirst()
            
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
                edgeStack.append(edge)
                continue
            } else {
                flipWithBucket(edge: edge)
                if edgesCross(edge1Point1: point1,
                              edge1Point2: point2,
                              edge2Point1: edge.vertex.point,
                              edge2Point2: edge.previousEdge.vertex.point) {
                    edgeStack.append(edge)
                }
            }
        }
        return true
    }
    
    func edgesCross(edge1Point1: TriangulationPoint,
                    edge1Point2: TriangulationPoint,
                    edge2Point1: TriangulationPoint,
                    edge2Point2: TriangulationPoint) -> Bool {
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
    
    func constrainWithHull(triangleData: TriangulationData,
                           hull: [TriangulationPoint]) -> Bool {
        if hull.count < 3 {
            return true
        }
        
        edgeGridBucket.build(triangulationData: triangleData)
        
        var index1 = hull.count - 1
        var index2 = 0
        while index2 < hull.count {
            let hullPoint1 = hull[index1]
            let hullPoint2 = hull[index2]
            
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
    
    func findIntersectingEdges(triangleData: TriangulationData,
                               hullPoint1: TriangulationPoint,
                               hullPoint2: TriangulationPoint) {
        
        edgeGridBucket.query(point1: hullPoint1,
                             point2: hullPoint2)
        
        for edge in edgeGridBucket.edges {
            let edge1Point2 = edge.vertex.point
            let edge1Point1 = edge.previousEdge.vertex.point
            
            var inverseExists = false
            for existingEdge in edgeStack {
                
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
                edgeStack.append(edge)
            }
        }
    }
    
    func removeSuperTriangle(point1: TriangulationPoint,
                             point2: TriangulationPoint,
                             point3: TriangulationPoint,
                             triangulationData: TriangulationData) {
        
        faceSet.removeAll(keepingCapacity: true)
        for vertex in triangulationData.vertices {
            if faceSet.contains(vertex.edge.face) {
                continue
            }
            
            let vertexPoint = vertex.point
            if vertexPoint == point1 || vertexPoint == point2 || vertexPoint == point3 {
                faceSet.insert(vertex.edge.face)
            }
        }
        
        for face in faceSet {
            removeFaceAndClearOpposites(face: face,
                                        triangulationData: triangulationData)
        }
    }
    
    //TODO: Bottleneck: This is taking 3,000+ loops each call.
    //static var containsEdgeMaxLoops = 0
    /*
    func containsEdge(triangleData: TriangulationData,
                      point1: TriangulationPoint ,
                      point2: TriangulationPoint) -> Bool {
        
        var loops = 0
        for edge in triangleData.edges {
            
            loops += 1
            
            let edgePoint2 = edge.vertex.point
            let edgePoint1 = edge.previousEdge.vertex.point
            
            if (edgePoint1 == point1 && edgePoint2 == point2) || (edgePoint1 == point2 && edgePoint2 == point1) {
                return true
            }
        }
        
        return false
    }
    */
    
    func splitTriangleFace(face: TriangulationFace,
                           point: TriangulationPoint,
                           triangulationData: TriangulationData) {
        
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
        
        for edge in edgeStack {
            if edge.oppositeEdge !== nil {
                continue
            }
            
            let pointA = edge.vertex.point
            let pointB = edge.previousEdge.vertex.point
            
            for oppositeEdge in edgeStack {
                
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
        
        edgeStack.removeAll(keepingCapacity: true)
        
        removeFace(face: face, triangulationData: triangulationData)
    }
    
    func createFace(edge: TriangulationEdge,
                       point: TriangulationPoint,
                       triangulationData: TriangulationData) {
        
        let point1 = point
        let point2 = edge.previousEdge.vertex.point
        let point3 = edge.vertex.point
        
        let vertex1 = partsFactory.withdrawVertex(point: point1)
        let vertex2 = partsFactory.withdrawVertex(point: point2)
        let vertex3 = partsFactory.withdrawVertex(point: point3)
        
        let edge1 = partsFactory.withdrawEdge(vertex: vertex3)
        let edge2 = partsFactory.withdrawEdge(vertex: vertex1)
        let edge3 = partsFactory.withdrawEdge(vertex: vertex2)
        
        let face = partsFactory.withdrawFace(edge: edge1)
        
        edge1.oppositeEdge = edge.oppositeEdge
        if edge1.oppositeEdge !== nil {
            edge.oppositeEdge.oppositeEdge = edge1
        }
        
        edgeStack.append(edge2); edgeStack.append(edge3)
        
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
    
    func removeFace(face: TriangulationFace,
                    triangulationData: TriangulationData) {
        
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
    
    func removeFaceAndClearOpposites(face: TriangulationFace,
                    triangulationData: TriangulationData) {
        
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
    
    func triangleIsClockwise(point1: TriangulationPoint, point2: TriangulationPoint, point3: TriangulationPoint) -> Bool {
        if (point1.x * point2.y + point3.x * point1.y + point2.x * point3.y - point1.x * point3.y - point3.x * point2.y - point2.x * point1.y) > 0.0 {
            return false
        } else {
            return true
        }
    }
    
    func quadIsConvex(point1: TriangulationPoint, point2: TriangulationPoint, point3: TriangulationPoint, point4: TriangulationPoint) -> Bool {
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
    
    func lineSegmentIntersectsLineSegment(line1Point1: TriangulationPoint,
                                          line1Point2: TriangulationPoint,
                                          line2Point1: TriangulationPoint,
                                          line2Point2: TriangulationPoint) -> Bool {
        
        let maxX2 = max(line2Point1.x, line2Point2.x)
        let minX1 = min(line1Point1.x, line1Point2.x)
        
        if maxX2 < minX1 {
            return false
        }
        
        let maxY2 = max(line2Point1.y, line2Point2.y)
        let minY1 = min(line1Point1.y, line1Point2.y)
        
        if maxY2 < minY1 {
            return false
        }
        
        let minX2 = min(line2Point1.x, line2Point2.x)
        let maxX1 = max(line1Point1.x, line1Point2.x)
        
        if minX2 > maxX1 {
            return false
        }
        
        let minY2 = min(line2Point1.y, line2Point2.y)
        let maxY1 = max(line1Point1.y, line1Point2.y)
        
        if minY2 > maxY1 {
            return false
        }
        
        func between(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) -> Bool {
            if fabsf(x1 - x2) > epsilon {
                return (((x1 <= x3) && (x3 <= x2)) || ((x1 >= x3) && (x3 >= x2)))
            } else {
                return ((y1 <= y3) && (y3 <= y2)) || ((y1 >= y3) && (y3 >= y2))
            }
        }
        
        let area1 = triangleArea(x1: line1Point1.x, y1: line1Point1.y, x2: line1Point2.x, y2: line1Point2.y, x3: line2Point1.x, y3: line2Point1.y)
        if fabsf(area1) < epsilon {
            if between(x1: line1Point1.x, y1: line1Point1.y, x2: line1Point2.x, y2: line1Point2.y, x3: line2Point1.x, y3: line2Point1.y) {
                return true
            } else {
                if triangleAreaAbsolute(x1: line1Point1.x, y1: line1Point1.y, x2: line1Point2.x, y2: line1Point2.y, x3: line2Point2.x, y3: line2Point2.y) < epsilon {
                    if between(x1: line2Point1.x, y1: line2Point1.y, x2: line2Point2.x, y2: line2Point2.y, x3: line1Point1.x, y3: line1Point1.y) {
                        return true
                    }
                    if between(x1: line2Point1.x, y1: line2Point1.y, x2: line2Point2.x, y2: line2Point2.y, x3: line1Point2.x, y3: line1Point2.y) {
                        return true
                    }
                    return false
                }
                return false
            }
        }
        let area2 = triangleArea(x1: line1Point1.x, y1: line1Point1.y, x2: line1Point2.x, y2: line1Point2.y, x3: line2Point2.x, y3: line2Point2.y)
        if fabsf(area2) <= epsilon {
            return between(x1: line1Point1.x, y1: line1Point1.y, x2: line1Point2.x, y2: line1Point2.y, x3: line2Point2.x, y3: line2Point2.y)
        }
        let area3 = triangleArea(x1: line2Point1.x, y1: line2Point1.y, x2: line2Point2.x, y2: line2Point2.y, x3: line1Point1.x, y3: line1Point1.y)
        if fabsf(area3) <= epsilon {
            if between(x1: line2Point1.x, y1: line2Point1.y, x2: line2Point2.x, y2: line2Point2.y, x3: line1Point1.x, y3: line1Point1.y) {
                return true
            } else {
                if triangleAreaAbsolute(x1: line2Point1.x, y1: line2Point1.y, x2: line2Point2.x, y2: line2Point2.y, x3: line1Point2.x, y3: line1Point2.y) < epsilon {
                    if between(x1: line1Point1.x, y1: line1Point1.y, x2: line1Point2.x, y2: line1Point2.y, x3: line2Point1.x, y3: line2Point1.y) {
                        return true
                    }
                    if between(x1: line1Point1.x, y1: line1Point1.y, x2: line1Point2.x, y2: line1Point2.y, x3: line2Point2.x, y3: line2Point2.y) {
                        return true
                    }
                    return false
                }
                return false
            }
        }
        let area4 = triangleArea(x1: line2Point1.x, y1: line2Point1.y, x2: line2Point2.x, y2: line2Point2.y, x3: line1Point2.x, y3: line1Point2.y)
        if fabsf(area4) <= epsilon {
            return between(x1: line2Point1.x, y1: line2Point1.y, x2: line2Point2.x, y2: line2Point2.y, x3: line1Point2.x, y3: line1Point2.y)
        }
        
        if ((area1 > 0.0) != (area2 > 0.0)) && ((area3 > 0.0) != (area4 > 0.0)) {
            return true
        } else {
            return false
        }
    }
    
    func triangleArea(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) -> Float {
        (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1)
    }
    
    func triangleAreaAbsolute(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) -> Float {
        let area = (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1)
        if area < 0.0 {
            return -area
        } else {
            return area
        }
    }
    
    func cross(x1: Float, y1: Float, x2: Float, y2: Float) -> Float {
        x1 * y2 - x2 * y1
    }
}
