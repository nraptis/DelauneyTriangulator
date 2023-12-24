//
//  PointInPolyBucket.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//

import Foundation

final class PolyPointBucket {
    
    private class PolyPointBucketNode {
        var lineSegments = Set<TriangulationLineSegment>()
    }
    
    private static let countH = 24
    
    private var nodes = [PolyPointBucketNode]()
    private var gridX: [Float]
    
    init() {
        
        gridX = [Float](repeating: 0.0, count: Self.countH)
        
        var x = 0
        while x < Self.countH {
            let node = PolyPointBucketNode()
            nodes.append(node)
            x += 1
        }
    }
    
    func reset() {
        var x = 0
        while x < Self.countH {
            nodes[x].lineSegments.removeAll(keepingCapacity: true)
            x += 1
        }
    }
    
    func build(lineSegments: [TriangulationLineSegment]) {
        
        guard lineSegments.count > 0 else {
            return
        }
        
        reset()
        
        let referenceEdge = lineSegments[0]
        let referenceEdgePoint1 = referenceEdge.point1!
        let referenceEdgePoint2 = referenceEdge.point2!
        
        var minX = min(referenceEdgePoint1.x, referenceEdgePoint2.x)
        var maxX = max(referenceEdgePoint1.x, referenceEdgePoint2.x)
        
        for lineSegment in lineSegments {
            let edgePoint1 = lineSegment.point1!
            let edgePoint2 = lineSegment.point2!
            
            minX = min(minX, edgePoint1.x); minX = min(minX, edgePoint2.x)
            maxX = max(maxX, edgePoint1.x); maxX = max(maxX, edgePoint2.x)
        }
        
        minX -= 0.05
        maxX += 0.05
        
        var x = 0
        while x < Self.countH {
            let percent = Float(x) / Float(Self.countH - 1)
            gridX[x] = minX + (maxX - minX) * percent
            x += 1
        }
        
        for lineSegment in lineSegments {
            let edgePoint1 = lineSegment.point1!
            let edgePoint2 = lineSegment.point2!
            
            let _minX = min(edgePoint1.x, edgePoint2.x)
            let _maxX = max(edgePoint1.x, edgePoint2.x)
            
            let lowerBoundX = lowerBoundX(value: _minX)
            let upperBoundX = upperBoundX(value: _maxX)
            
            x = lowerBoundX
            while x <= upperBoundX {
                nodes[x].lineSegments.insert(lineSegment)
                x += 1
            }
        }
    }
    
    func query(x: Float, y: Float) -> Bool {
        
        var result = false
        
        if x >= gridX[0] && x <= gridX[Self.countH - 1] {
            let indexX = lowerBoundX(value: x)
            
            for lineSegment in nodes[indexX].lineSegments {
                
                let point1 = lineSegment.point1!
                let point2 = lineSegment.point2!
                
                if rangesContainsValue(start: point1.x, end: point2.x, value: x) {
                    
                    if point1.y <= y || point2.y <= y {
                            if lineSegmentIntersectsLineSegment(line1Point1X: x,
                                                                     line1Point1Y: y,
                                                                     line1Point2X: x,
                                                                     line1Point2Y: y - 2048.0,
                                                                     line2Point1X: point1.x,
                                                                     line2Point1Y: point1.y,
                                                                     line2Point2X: point2.x,
                                                                     line2Point2Y: point2.y) {
                            result = !result
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    func rangesContainsValue(start: Float, end: Float, value: Float) -> Bool {
        if value >= start && value <= end {
            return true
        }
        if value >= end && value <= start {
            return true
        }
        return false
    }
    
    func lowerBoundX(value: Float) -> Int {
        var start = 0
        var end = Self.countH
        while start != end {
            let mid = (start + end) >> 1
            if value > gridX[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
    }
    
    func upperBoundX(value: Float) -> Int {
        var start = 0
        var end = Self.countH
        while start != end {
            let mid = (start + end) >> 1
            if value >= gridX[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
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
    
    func between(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) -> Bool {
        if fabsf(x1 - x2) > epsilon {
            return (((x1 <= x3) && (x3 <= x2)) || ((x1 >= x3) && (x3 >= x2)))
        } else {
            return ((y1 <= y3) && (y3 <= y2)) || ((y1 >= y3) && (y3 >= y2))
        }
    }
    
    private let epsilon = Float(0.00001)
    func lineSegmentIntersectsLineSegment(line1Point1X: Float,
                                          line1Point1Y: Float,
                                          line1Point2X: Float,
                                          line1Point2Y: Float,
                                          line2Point1X: Float,
                                          line2Point1Y: Float,
                                          line2Point2X: Float,
                                          line2Point2Y: Float) -> Bool {
        
        let area1 = triangleArea(x1: line1Point1X, y1: line1Point1Y, x2: line1Point2X, y2: line1Point2Y, x3: line2Point1X, y3: line2Point1Y)
        if fabsf(area1) < epsilon {
            if between(x1: line1Point1X, y1: line1Point1Y, x2: line1Point2X, y2: line1Point2Y, x3: line2Point1X, y3: line2Point1Y) {
                return true
            } else {
                if fabsf(triangleArea(x1: line1Point1X, y1: line1Point1Y, x2: line1Point2X, y2: line1Point2Y, x3: line2Point2X, y3: line2Point2Y)) < epsilon {
                    if between(x1: line2Point1X, y1: line2Point1Y, x2: line2Point2X, y2: line2Point2Y, x3: line1Point1X, y3: line1Point1Y) {
                        return true
                    }
                    if between(x1: line2Point1X, y1: line2Point1Y, x2: line2Point2X, y2: line2Point2Y, x3: line1Point2X, y3: line1Point2Y) {
                        return true
                    }
                    return false
                }
                return false
            }
        }
        let area2 = triangleArea(x1: line1Point1X, y1: line1Point1Y, x2: line1Point2X, y2: line1Point2Y, x3: line2Point2X, y3: line2Point2Y)
        if fabsf(area2) <= epsilon {
            return between(x1: line1Point1X, y1: line1Point1Y, x2: line1Point2X, y2: line1Point2Y, x3: line2Point2X, y3: line2Point2Y)
        }
        let area3 = triangleArea(x1: line2Point1X, y1: line2Point1Y, x2: line2Point2X, y2: line2Point2Y, x3: line1Point1X, y3: line1Point1Y)
        if fabsf(area3) <= epsilon {
            if between(x1: line2Point1X, y1: line2Point1Y, x2: line2Point2X, y2: line2Point2Y, x3: line1Point1X, y3: line1Point1Y) {
                return true
            } else {
                if fabsf(triangleArea(x1: line2Point1X, y1: line2Point1Y, x2: line2Point2X, y2: line2Point2Y, x3: line1Point2X, y3: line1Point2Y)) < epsilon {
                    if between(x1: line1Point1X, y1: line1Point1Y, x2: line1Point2X, y2: line1Point2Y, x3: line2Point1X, y3: line2Point1Y) {
                        return true
                    }
                    if between(x1: line1Point1X, y1: line1Point1Y, x2: line1Point2X, y2: line1Point2Y, x3: line2Point2X, y3: line2Point2Y) {
                        return true
                    }
                    return false
                }
                return false
            }
        }
        let area4 = triangleArea(x1: line2Point1X, y1: line2Point1Y, x2: line2Point2X, y2: line2Point2Y, x3: line1Point2X, y3: line1Point2Y)
        if fabsf(area4) <= epsilon {
            return between(x1: line2Point1X, y1: line2Point1Y, x2: line2Point2X, y2: line2Point2Y, x3: line1Point2X, y3: line1Point2Y)
        }
        return ((area1 > 0.0) != (area2 > 0.0)) && ((area3 > 0.0) != (area4 > 0.0))
    }
    
}
