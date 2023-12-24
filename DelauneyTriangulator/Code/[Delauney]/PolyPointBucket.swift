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
        let indexX = lowerBoundX(value: x)
        if indexX < Self.countH {
            for lineSegment in nodes[indexX].lineSegments {
                
                let point1 = lineSegment.point1!
                let point2 = lineSegment.point2!
                
                let x1: Float
                let y1: Float
                let x2: Float
                let y2: Float
                if point1.x < point2.x {
                    x1 = point1.x
                    y1 = point1.y
                    x2 = point2.x
                    y2 = point2.y
                } else {
                    x1 = point2.x
                    y1 = point2.y
                    x2 = point1.x
                    y2 = point1.y
                }
                
                if x >= x1 && x <= x2 {
                    if (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1) <= 0.0 {
                        result = !result
                    }
                }
            }
        }
        return result
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
}
