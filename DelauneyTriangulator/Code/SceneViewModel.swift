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
    
    var polygonPointCountString: String = "42"
    
    var polygon = [Point]()
    
    var width = Float(320.0)
    var height = Float(320.0)
    
    var triangulationMode = TriangulationMode.delauney
    
    func generateRandomPolygon(width: Float, height: Float, count: Int) {
        
        var count = count
        if count < 3 { count = 3 }
        if count > 75 { count = 75 }
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
                
                
                if (loops % 10000) == 0 && loops != 0 {
                    print("Loops = \(loops)")
                }
            }
        }
    }
    
    private func generateRandomPolygonHelper(width: Float, height: Float, count: Int) -> Bool {
        
        var loops = 0
        
        polygon.removeAll()
        
        let closeThreshold = Float(56.0 * 56.0)
        
        var edgeBuffer = Float(42.0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            edgeBuffer = 90.0
        }
        
        let minX = edgeBuffer
        let maxX = (width - edgeBuffer - edgeBuffer)
        
        let minY = edgeBuffer
        let maxY = (height - edgeBuffer - edgeBuffer)
        
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
        
        let lastSegmentPoint0 = polygon[polygon.count - 2]
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
        
        /*
        index = 0
        while index < (polygon.count - 2) {
            
            let closestPoint = Math.segmentClosestPoint(point: polygon[index],
                                                        linePoint1: lastSegmentPoint0,
                                                        linePoint2: lastSegmentPoint1)
            
            let distanceSquared = Math.distanceSquared(point1: closestPoint,
                                                       point2: polygon[index])
            if distanceSquared <= closeThreshold {
                return false
            }
            
            index += 1
        }
        */
        
        return true
    }
    
}
