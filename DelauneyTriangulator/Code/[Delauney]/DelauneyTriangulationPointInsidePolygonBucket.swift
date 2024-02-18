//
//  DelauneyTriangulationPointInsidePolygonBucket.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/26/23.
//

import Foundation

final class DelauneyTriangulationPointInsidePolygonBucket {
    
    private class DelauneyTriangulationPointInsidePolygonBucketNode {
        
        var triangulationLineSegments = [DelauneyTriangulationLineSegment]()
        var triangulationLineSegmentCount = 0
        
        func remove(_ triangulationLineSegment: DelauneyTriangulationLineSegment) {
            for checkIndex in 0..<triangulationLineSegmentCount {
                if triangulationLineSegments[checkIndex] === triangulationLineSegment {
                    remove(checkIndex)
                    return
                }
            }
        }
        
        func remove(_ index: Int) {
            if index >= 0 && index < triangulationLineSegmentCount {
                let triangulationLineSegmentCount1 = triangulationLineSegmentCount - 1
                var triangulationLineSegmentIndex = index
                while triangulationLineSegmentIndex < triangulationLineSegmentCount1 {
                    triangulationLineSegments[triangulationLineSegmentIndex] = triangulationLineSegments[triangulationLineSegmentIndex + 1]
                    triangulationLineSegmentIndex += 1
                }
                triangulationLineSegmentCount -= 1
            }
        }
        
        func add(_ triangulationLineSegment: DelauneyTriangulationLineSegment) {
            while triangulationLineSegments.count <= triangulationLineSegmentCount {
                triangulationLineSegments.append(triangulationLineSegment)
            }
            triangulationLineSegments[triangulationLineSegmentCount] = triangulationLineSegment
            triangulationLineSegmentCount += 1
        }
        
    }
    
    private static let countH = 24
    
    private var nodes = [DelauneyTriangulationPointInsidePolygonBucketNode]()
    private var gridX: [Float]
    
    init() {
        gridX = [Float](repeating: 0.0, count: Self.countH)
        var x = 0
        while x < Self.countH {
            let node = DelauneyTriangulationPointInsidePolygonBucketNode()
            nodes.append(node)
            x += 1
        }
    }
    
    func reset() {
        var x = 0
        while x < Self.countH {
            nodes[x].triangulationLineSegmentCount = 0
            x += 1
        }
    }
    
    func build(triangulationLineSegments: [DelauneyTriangulationLineSegment], triangulationLineSegmentCount: Int) {
        
        reset()
        
        guard triangulationLineSegmentCount > 0 else {
            return
        }
        
        let referenceDelauneyTriangulationLineSegment = triangulationLineSegments[0]
        
        var minX = min(referenceDelauneyTriangulationLineSegment.point1.x, referenceDelauneyTriangulationLineSegment.point2.x)
        var maxX = max(referenceDelauneyTriangulationLineSegment.point1.x, referenceDelauneyTriangulationLineSegment.point2.x)
        
        var triangulationLineSegmentIndex = 1
        while triangulationLineSegmentIndex < triangulationLineSegmentCount {
            let triangulationLineSegment = triangulationLineSegments[triangulationLineSegmentIndex]
            
            minX = min(minX, triangulationLineSegment.point1.x); minX = min(minX, triangulationLineSegment.point2.x)
            maxX = max(maxX, triangulationLineSegment.point1.x); maxX = max(maxX, triangulationLineSegment.point2.x)
            
            triangulationLineSegmentIndex += 1
        }
        
        minX -= 1.0
        maxX += 1.0
        
        var x = 0
        while x < Self.countH {
            let percent = Float(x) / Float(Self.countH - 1)
            gridX[x] = minX + (maxX - minX) * percent
            x += 1
        }
        
        for triangulationLineSegmentIndex in 0..<triangulationLineSegmentCount {
            let triangulationLineSegment = triangulationLineSegments[triangulationLineSegmentIndex]
            
            let _minX = min(triangulationLineSegment.point1.x, triangulationLineSegment.point2.x)
            let _maxX = max(triangulationLineSegment.point1.x, triangulationLineSegment.point2.x)
            
            let lowerBoundX = lowerBoundX(value: _minX)
            let upperBoundX = upperBoundX(value: _maxX)
            
            x = lowerBoundX
            while x <= upperBoundX {
                nodes[x].add(triangulationLineSegment)
                x += 1
            }
        }
    }
    
    func query(x: Float, y: Float) -> Bool {
        var result = false
        let indexX = lowerBoundX(value: x)
        if indexX < Self.countH {
            for triangulationLineSegmentIndex in 0..<nodes[indexX].triangulationLineSegmentCount {
                let triangulationLineSegment = nodes[indexX].triangulationLineSegments[triangulationLineSegmentIndex]
                
                let x1: Float
                let y1: Float
                let x2: Float
                let y2: Float
                if triangulationLineSegment.point1.x < triangulationLineSegment.point2.x {
                    x1 = triangulationLineSegment.point1.x
                    y1 = triangulationLineSegment.point1.y
                    x2 = triangulationLineSegment.point2.x
                    y2 = triangulationLineSegment.point2.y
                } else {
                    x1 = triangulationLineSegment.point2.x
                    y1 = triangulationLineSegment.point2.y
                    x2 = triangulationLineSegment.point1.x
                    y2 = triangulationLineSegment.point1.y
                }
                if x > x1 && x <= x2 {
                    if (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1) < 0.0 {
                        result = !result
                    }
                }
            }
        }
        return result
    }
    
    private func lowerBoundX(value: Float) -> Int {
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
    
    private func upperBoundX(value: Float) -> Int {
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
