//
//  LineSegmentBucket.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/31/23.
//

import Foundation

final class DelauneyTriangulationEdgeBucket {
    
    private class DelauneyTriangulationEdgeBucketNode {
        var triangulationEdges = [DelauneyTriangulationEdge]()
        var triangulationEdgeCount = 0
        
        func remove(_ triangulationEdge: DelauneyTriangulationEdge) {
            for checkIndex in 0..<triangulationEdgeCount {
                if triangulationEdges[checkIndex] === triangulationEdge {
                    remove(checkIndex)
                    return
                }
            }
        }
        
        func remove(_ index: Int) {
            if index >= 0 && index < triangulationEdgeCount {
                let triangulationEdgeCount1 = triangulationEdgeCount - 1
                var triangulationEdgeIndex = index
                while triangulationEdgeIndex < triangulationEdgeCount1 {
                    triangulationEdges[triangulationEdgeIndex] = triangulationEdges[triangulationEdgeIndex + 1]
                    triangulationEdgeIndex += 1
                }
                triangulationEdgeCount -= 1
            }
        }
        
        func add(_ triangulationEdge: DelauneyTriangulationEdge) {
            while triangulationEdges.count <= triangulationEdgeCount {
                triangulationEdges.append(triangulationEdge)
            }
            triangulationEdges[triangulationEdgeCount] = triangulationEdge
            triangulationEdgeCount += 1
        }
    }
    
    private static let countH = 24
    private static let countV = 24
    
    private var grid = [[DelauneyTriangulationEdgeBucketNode]]()
    private var gridX: [Float]
    private var gridY: [Float]
    
    private(set) var triangulationEdges: [DelauneyTriangulationEdge]
    private(set) var triangulationEdgeCount = 0
    
    init() {
        
        gridX = [Float](repeating: 0.0, count: Self.countH)
        gridY = [Float](repeating: 0.0, count: Self.countV)
        triangulationEdges = [DelauneyTriangulationEdge]()
        
        var x = 0
        while x < Self.countH {
            var column = [DelauneyTriangulationEdgeBucketNode]()
            var y = 0
            while y < Self.countV {
                let node = DelauneyTriangulationEdgeBucketNode()
                column.append(node)
                y += 1
            }
            grid.append(column)
            x += 1
        }
    }
    
    func reset() {
        var x = 0
        var y = 0
        while x < Self.countH {
            y = 0
            while y < Self.countV {
                grid[x][y].triangulationEdgeCount = 0
                y += 1
            }
            x += 1
        }
        
        triangulationEdgeCount = 0
    }
    
    func build(triangulationEdges: Set<DelauneyTriangulationEdge>) {
        
        reset()
        
        guard triangulationEdges.count > 0 else {
            return
        }
        
        let referenceDelauneyTriangulationEdge = triangulationEdges.first!
        
        let referenceEdgePoint1 = referenceDelauneyTriangulationEdge.vertex.point
        let referenceEdgePoint2 = referenceDelauneyTriangulationEdge.previousEdge.vertex.point
        
        var minX = min(referenceEdgePoint1.x, referenceEdgePoint1.x)
        var maxX = max(referenceEdgePoint1.x, referenceEdgePoint1.y)
        var minY = min(referenceEdgePoint1.y, referenceEdgePoint2.y)
        var maxY = max(referenceEdgePoint1.y, referenceEdgePoint2.y)
        
        
        for triangulationEdge in triangulationEdges {
            
            let edgePoint1 = triangulationEdge.vertex.point
            let edgePoint2 = triangulationEdge.previousEdge.vertex.point
            
            minX = min(minX, edgePoint1.x); minX = min(minX, edgePoint2.x)
            maxX = max(maxX, edgePoint1.x); maxX = max(maxX, edgePoint2.x)
            minY = min(minY, edgePoint1.y); minY = min(minY, edgePoint2.y)
            maxY = max(maxY, edgePoint1.y); maxY = max(maxY, edgePoint2.y)
        }
        
        minX -= 1.0
        maxX += 1.0
        minY -= 1.0
        maxY += 1.0
        
        var x = 0
        while x < Self.countH {
            let percent = Float(x) / Float(Self.countH - 1)
            gridX[x] = minX + (maxX - minX) * percent
            x += 1
        }
        
        var y = 0
        while y < Self.countV {
            let percent = Float(y) / Float(Self.countV - 1)
            gridY[y] = minY + (maxY - minY) * percent
            y += 1
        }
        
        for triangulationEdge in triangulationEdges {
            
            let edgePoint1 = triangulationEdge.vertex.point
            let edgePoint2 = triangulationEdge.previousEdge.vertex.point
            
            let _minX = min(edgePoint1.x, edgePoint2.x)
            let _maxX = max(edgePoint1.x, edgePoint2.x)
            let _minY = min(edgePoint1.y, edgePoint2.y)
            let _maxY = max(edgePoint1.y, edgePoint2.y)
            
            let lowerBoundX = lowerBoundX(value: _minX)
            let upperBoundX = upperBoundX(value: _maxX)
            let lowerBoundY = lowerBoundY(value: _minY)
            let upperBoundY = upperBoundY(value: _maxY)
            
            x = lowerBoundX
            while x <= upperBoundX {
                y = lowerBoundY
                while y <= upperBoundY {
                    grid[x][y].add(triangulationEdge)
                    y += 1
                }
                x += 1
            }
        }
    }
    
    func remove(triangulationEdge: DelauneyTriangulationEdge) {
        
        let edgePoint1 = triangulationEdge.vertex.point
        let edgePoint2 = triangulationEdge.previousEdge.vertex.point
        
        let _minX = min(edgePoint1.x, edgePoint2.x)
        let _maxX = max(edgePoint1.x, edgePoint2.x)
        let _minY = min(edgePoint1.y, edgePoint2.y)
        let _maxY = max(edgePoint1.y, edgePoint2.y)
        
        let lowerBoundX = lowerBoundX(value: _minX)
        let upperBoundX = upperBoundX(value: _maxX)
        let lowerBoundY = lowerBoundY(value: _minY)
        let upperBoundY = upperBoundY(value: _maxY)
        
        var x = 0
        var y = 0
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                grid[x][y].remove(triangulationEdge)
                y += 1
            }
            x += 1
        }
    }
    
    func add(triangulationEdge: DelauneyTriangulationEdge) {
            
        let edgePoint1 = triangulationEdge.vertex.point
        let edgePoint2 = triangulationEdge.previousEdge.vertex.point
        
        let _minX = min(edgePoint1.x, edgePoint2.x)
        let _maxX = max(edgePoint1.x, edgePoint2.x)
        let _minY = min(edgePoint1.y, edgePoint2.y)
        let _maxY = max(edgePoint1.y, edgePoint2.y)
        
        let lowerBoundX = lowerBoundX(value: _minX)
        let upperBoundX = upperBoundX(value: _maxX)
        let lowerBoundY = lowerBoundY(value: _minY)
        let upperBoundY = upperBoundY(value: _maxY)
        
        var x = 0
        var y = 0
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                grid[x][y].add(triangulationEdge)
                y += 1
            }
            x += 1
        }
    }
    
    func query(point1: DelauneyTriangulationPoint, point2: DelauneyTriangulationPoint) {
        query(minX: min(point1.x, point2.x),
              maxX: max(point1.x, point2.x),
              minY: min(point1.y, point2.y),
              maxY: max(point1.y, point2.y))
    }
    
    func query(minX: Float, maxX: Float, minY: Float, maxY: Float) {
        
        triangulationEdgeCount = 0
        
        let lowerBoundX = lowerBoundX(value: minX)
        var upperBoundX = upperBoundX(value: maxX)
        let lowerBoundY = lowerBoundY(value: minY)
        var upperBoundY = upperBoundY(value: maxY)
        
        if upperBoundX >= Self.countH {
            upperBoundX = Self.countH - 1
        }
        
        if upperBoundY >= Self.countV {
            upperBoundY = Self.countV - 1
        }
        
        var x = 0
        var y = 0
        
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                for triangulationEdgeIndex in 0..<grid[x][y].triangulationEdgeCount {
                    grid[x][y].triangulationEdges[triangulationEdgeIndex].isBucketed = false
                }
                y += 1
            }
            x += 1
        }
        
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                for triangulationEdgeIndex in 0..<grid[x][y].triangulationEdgeCount {
                    let triangulationEdge = grid[x][y].triangulationEdges[triangulationEdgeIndex]
                    if triangulationEdge.isBucketed == false {
                        triangulationEdge.isBucketed = true
                        
                        while triangulationEdges.count <= triangulationEdgeCount {
                            triangulationEdges.append(triangulationEdge)
                        }
                        triangulationEdges[triangulationEdgeCount] = triangulationEdge
                        triangulationEdgeCount += 1
                    }
                }
                y += 1
            }
            x += 1
        }
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
    
    func lowerBoundY(value: Float) -> Int {
        var start = 0
        var end = Self.countV
        while start != end {
            let mid = (start + end) >> 1
            if value > gridY[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
        
    }
    
    func upperBoundY(value: Float) -> Int {
        var start = 0
        var end = Self.countV
        while start != end {
            let mid = (start + end) >> 1
            if value >= gridY[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
    }
}
