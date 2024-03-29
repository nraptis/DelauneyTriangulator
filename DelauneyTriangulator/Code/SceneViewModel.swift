//
//  TriangleViewModel.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//

import Observation
import UIKit

@Observable class SceneViewModel {
    
    enum TriangulationMode: Identifiable, CaseIterable, CustomStringConvertible {
        case delauney
        case constrainedDelauney
        var id: Int {
            switch self {
            case .delauney:
                return 0
            case .constrainedDelauney:
                return 1
            }
        }
        var description: String {
            switch self {
            case .delauney:
                return "Delauney"
            case .constrainedDelauney:
                return "Constrained Delauney"
            }
        }
    }
    
    typealias Point = Math.Point
    
    var sceneModel = SceneModel()
    var number = 9
    
    var polygonPointCountString: String = "40"
    var innerPointCountString: String = "512"
    
    var polygon = [Point]()
    var innerPoints = [Point]()
    
    var width = Float(320.0)
    var height = Float(320.0)
    
    var triangulationMode = TriangulationMode.constrainedDelauney
    
    func generateRandomPolygon(width: Float, height: Float, count: Int) {
        
        var count = count
        if count < 3 { count = 3 }
        if count > 100 { count = 100 }
        polygonPointCountString = String(count)
        
        var reloop = true
        var loops = 0
        while reloop == true {
            if generateRandomPolygonHelper(width: width,
                                           height: height,
                                           count: count) {
                
                reloop = false
                
            } else {
                loops += 1
                
                if (loops % 5000) == 0 && loops != 0 {
                    
                    count -= 4
                    if count < 3 {
                        count = 3
                    }
                }
            }
        }
        eliminatePointsThatAreOnPolyLines()
    }
    
    private func generateRandomPolygonHelper(width: Float, height: Float, count: Int) -> Bool {
        
        var loops = 0
        
        polygon.removeAll()
        
        let closeThreshold = Float(56.0 * 56.0)
        
        var edgeBuffer = Float(16.0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            edgeBuffer = 80.0
        }
        
        let minX = edgeBuffer
        let maxX = (width - edgeBuffer)
        let minY = edgeBuffer
        let maxY = (height - edgeBuffer)
        
        let newX = Float.random(in: minX...maxX)
        let newY = Float.random(in: minY...maxY)
        polygon.append(Point(x: newX, y: newY))
        
        let maxHop = Float(186.0)
        let normalHop = Float(92.0)
        let smallestHop = Float(36.0)
        
        while polygon.count < count {
            
            var tries = 0
            
            let lastX = polygon[polygon.count - 1].x
            let lastY = polygon[polygon.count - 1].y
            
            while tries < 512 {
                
                let hop: Float
                if Int.random(in: 0...8) == 4 {
                    hop = Float.random(in: smallestHop...maxHop)
                } else {
                    hop = Float.random(in: smallestHop...normalHop)
                }
                
                let angle = Float.random(in: 0...(Float.pi * 2.0))
                
                let dirX = sinf(angle)
                let dirY = cosf(angle)
                
                let newX = lastX + dirX * hop
                let newY = lastY + dirY * hop
                
                if polygon.count > 1 {
                    let lastPoint2 = polygon[polygon.count - 2]
                    let lastPoint1 = polygon[polygon.count - 1]
                    
                    let lastAngle = atan2f(lastPoint1.x - lastPoint2.x, lastPoint1.y - lastPoint2.y)
                    let newAngle = atan2f(newX - lastPoint1.x, newY - lastPoint1.y)
                    
                    let angleDifference = Math.distanceBetweenAnglesAbsolute(lastAngle, newAngle)
                    if angleDifference >= (Float.pi * 0.75) {
                        tries += 1
                        continue
                    }
                }
                
                if newX >= minX && newX <= maxX && newY >= minY && newY <= maxY {
                
                    let newPoint = Point(x: newX, y: newY)
                    
                    var index1 = polygon.count - 3
                    var index2 = polygon.count - 2
                    var intersects = false
                    
                    while index1 >= 0 && intersects == false {
                        
                        let checkPoint1 = polygon[index1]
                        let checkPoint2 = polygon[index2]
                        
                        if Math.lineSegmentIntersectsLineSegment(line1Point1: polygon[polygon.count - 1],
                                                                 line1Point2: newPoint,
                                                                 line2Point1: checkPoint1,
                                                                 line2Point2: checkPoint2) {
                            intersects = true
                        }
                        
                        let closestPoint = Math.segmentClosestPoint(point: newPoint,
                                                                    linePoint1: checkPoint1,
                                                                    linePoint2: checkPoint2)
                        
                        let distanceSquared = Math.distanceSquared(point1: closestPoint, point2: newPoint)
                        if distanceSquared <= closeThreshold {
                            intersects = true
                        }
                        
                        loops += 1
                        index1 -= 1
                        index2 -= 1
                    }
                    
                    if intersects == false {
                        polygon.append(Point(x: newX, y: newY))
                        break
                    } else {
                        tries += 1
                    }
                } else {
                    tries += 1
                }
            }
            if tries >= 512 {
                return false
            }
        }
        
        if polygon.count < count {
            return false
        }
        
        if !Math.polygonIsSimple(polygon) {
            return false
        }
        
        let lastSegmentPoint1 = polygon[polygon.count - 1]
        let lastSegmentPoint2 = polygon[0]
        
        var index = 1
        while index < (polygon.count - 1) {
            
            let closestPoint = Math.segmentClosestPoint(point: polygon[index],
                                                        linePoint1: lastSegmentPoint1,
                                                        linePoint2: lastSegmentPoint2)
            
            let distanceSquared = Math.distanceSquared(point1: closestPoint,
                                                       point2: polygon[index])
            if distanceSquared <= closeThreshold {
                return false
            }
            
            index += 1
        }
        return true
    }
    
    func generateRandomPoints(width: Float, height: Float, count: Int) {
        
        
        var count = count
        if count < 0 { count = 0 }
        if count > 2048 { count = 2048 }
        innerPointCountString = String(count)
        
        innerPoints.removeAll(keepingCapacity: true)
        
        let closeThreshold = Float(12.0 * 12.0)
        
        var edgeBuffer = Float(8.0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            edgeBuffer = 24.0
        }
        
        let minX = edgeBuffer
        let maxX = (width - edgeBuffer)
        let minY = edgeBuffer
        let maxY = (height - edgeBuffer)
        
        while innerPoints.count < count {
            
            var tries = 0
            
            while tries < 2048 {
                
                let newX = Float.random(in: minX...maxX)
                let newY = Float.random(in: minY...maxY)
                let newPoint = Point(x: newX,
                                     y: newY)
                
                var overlap = false
                
                for point in innerPoints {
                    let distanceSquared = Math.distanceSquared(point1: point, point2: newPoint)
                    if distanceSquared < closeThreshold {
                        overlap = true
                        break
                    }
                }
                
                for point in polygon {
                    let distanceSquared = Math.distanceSquared(point1: point, point2: newPoint)
                    if distanceSquared < closeThreshold {
                        overlap = true
                        break
                    }
                }
                
                if overlap == false {
                    innerPoints.append(newPoint)
                    break
                } else {
                    tries += 1
                }
            }
            
            if tries >= 2048 {
                return
            }
        }
        eliminatePointsThatAreOnPolyLines()
    }
    
    func eliminatePointsThatAreOnPolyLines() {
        
        var keepPoints = [Point]()
        
        for point in innerPoints {
            
            var index1 = polygon.count - 1
            var index2 = 0
            var onLine = false
            while index2 < polygon.count {
                let lp1 = polygon[index1]
                let lp2 = polygon[index2]
                
                let closest = Math.segmentClosestPoint(point: point,
                                                       linePoint1: lp1,
                                                       linePoint2: lp2)
                
                let dist = Math.distanceSquared(point1: closest,
                                                point2: point)
                
                if dist <= (5.0 * 5.0) {
                    onLine = true
                }
                
                index1 = index2
                index2 += 1
            }
            
            if !onLine {
                keepPoints.append(point)
            }
            
        }
        innerPoints = keepPoints
    }
}
