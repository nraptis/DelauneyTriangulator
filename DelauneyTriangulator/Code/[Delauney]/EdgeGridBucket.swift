//
//  EdgeBucketGrid.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/23/23.
//

import Foundation

final class EdgeGridBucket {
    
    private class EdgeGridBucketNode {
        var edges = Set<TriangulationEdge>()
    }
    
    private static let countH = 24
    private static let countV = 24
    
    private var grid = [[EdgeGridBucketNode]]()
    private var gridX: [Float]
    private var gridY: [Float]
    
    private(set) var edges: [TriangulationEdge]
    
    init() {
        
        gridX = [Float](repeating: 0.0, count: Self.countH)
        gridY = [Float](repeating: 0.0, count: Self.countV)
        edges = [TriangulationEdge]()
        
        var x = 0
        while x < Self.countH {
            var column = [EdgeGridBucketNode]()
            var y = 0
            while y < Self.countV {
                let node = EdgeGridBucketNode()
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
                grid[x][y].edges.removeAll()
                y += 1
            }
            x += 1
        }
    }
    
    func build(triangulationData: TriangulationData) {
        
        guard triangulationData.edges.count > 0 else {
            edges.removeAll(keepingCapacity: true)
            return
        }
        
        reset()
        
        let referenceEdge = triangulationData.edges.first!
        let referenceEdgePoint1 = referenceEdge.vertex.point
        let referenceEdgePoint2 = referenceEdge.previousEdge.vertex.point
        
        var minX = min(referenceEdgePoint1.x, referenceEdgePoint2.x)
        var maxX = max(referenceEdgePoint1.x, referenceEdgePoint2.x)
        var minY = min(referenceEdgePoint1.y, referenceEdgePoint2.y)
        var maxY = max(referenceEdgePoint1.y, referenceEdgePoint2.y)
        
        for edge in triangulationData.edges {
            let edgePoint1 = edge.vertex.point
            let edgePoint2 = edge.previousEdge.vertex.point
            
            minX = min(minX, edgePoint1.x); minX = min(minX, edgePoint2.x)
            maxX = max(maxX, edgePoint1.x); maxX = max(maxX, edgePoint2.x)
            minY = min(minY, edgePoint1.y); minY = min(minY, edgePoint2.y)
            maxY = max(maxY, edgePoint1.y); maxY = max(maxY, edgePoint2.y)
        }
        
        minX -= 0.05; maxX += 0.05
        minY -= 0.05; maxY += 0.05
        
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
        
        for edge in triangulationData.edges {
            let edgePoint1 = edge.vertex.point
            let edgePoint2 = edge.previousEdge.vertex.point
            
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
                    grid[x][y].edges.insert(edge)
                    y += 1
                }
                x += 1
            }
        }
    }
    
    func query(point1: TriangulationPoint, point2: TriangulationPoint) {
        
        edges.removeAll(keepingCapacity: true)
        
        let _minX = min(point1.x, point2.x)
        let _maxX = max(point1.x, point2.x)
        let _minY = min(point1.y, point2.y)
        let _maxY = max(point1.y, point2.y)
        
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
                for edge in grid[x][y].edges {
                    edge.isTagged = false
                }
                y += 1
            }
            x += 1
        }
        
        x = lowerBoundX
        while x <= upperBoundX {
            y = lowerBoundY
            while y <= upperBoundY {
                for edge in grid[x][y].edges {
                    if edge.isTagged == false {
                        edge.isTagged = true
                        edges.append(edge)
                    }
                }
                y += 1
            }
            x += 1
        }
    }
    
    func remove(edge: TriangulationEdge) {
            
        let edgePoint1 = edge.vertex.point
        let edgePoint2 = edge.previousEdge.vertex.point
        
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
                grid[x][y].edges.remove(edge)
                y += 1
            }
            x += 1
        }
    }
    
    func add(edge: TriangulationEdge) {
            
        let edgePoint1 = edge.vertex.point
        let edgePoint2 = edge.previousEdge.vertex.point
        
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
                grid[x][y].edges.insert(edge)
                y += 1
            }
            x += 1
        }
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
