//
//  TriangleScene.swift
//  DelauneyTriangulator
//
//  Created by Nicky Taylor on 12/23/23.
//
import Foundation
import Metal
import UIKit
import simd

struct DrawEdge: Hashable {
    var point1: TriangulationPoint
    var point2: TriangulationPoint
    
    init(point1: TriangulationPoint, point2: TriangulationPoint) {
        
        self.point1 = point1
        self.point2 = point2
    }
}


class TriangleScene: GraphicsDelegate {
    
    unowned var sceneViewModel: SceneViewModel!
    unowned var graphics: Graphics!
    
    let width: Float
    let height: Float
    let width2: Float
    let height2: Float
    
    let triangleBuffer = IndexTriangleBufferSpriteColored2D()
    
    let smallLineBuffer = IndexTriangleBufferSpriteColored2D()
    let largeLineBuffer = IndexTriangleBufferSpriteColored2D()
    
    let smallDotBuffer = IndexTriangleBufferSpriteColored2D()
    let largeDotBuffer = IndexTriangleBufferSpriteColored2D()
    
    let whiteSquareSprite = Sprite2D()
    
    let smallDotSprite = Sprite2D()
    let largeDotSprite = Sprite2D()
    
    let smallLineSprite = Sprite2D()
    let largeLineSprite = Sprite2D()
    
    init(width: Float, height: Float) {

        self.width = width
        self.height = height
        
        width2 = Float(Int(width * 0.5 + 0.5))
        height2 = Float(Int(height * 0.5 + 0.5))
        
        print("[++] TriangleScene")
    }
    
    deinit {
        print("[--] TriangleScene")
    }
    
    func initialize() {

    }
    
    func load() {
        
        let whiteSquareTexture = graphics.loadTexture(fileName: "white_square_32_32.png")
        whiteSquareSprite.load(graphics: graphics, texture: whiteSquareTexture, scaleFactor: 1.0)

        smallDotSprite.loadScaled(graphics: graphics, name: "jiggle_tan_point_small", extension: "png")
        largeDotSprite.loadScaled(graphics: graphics, name: "jiggle_tan_point_large", extension: "png")
        smallLineSprite.loadScaled(graphics: graphics, name: "jiggle_tan_line", extension: "png")
        largeLineSprite.loadScaled(graphics: graphics, name: "jiggle_poly_line", extension: "png")
        
        triangleBuffer.load(graphics: graphics, sprite: whiteSquareSprite)
        triangleBuffer.blendMode = .alpha
        
        smallLineBuffer.load(graphics: graphics, sprite: smallLineSprite)
        smallLineBuffer.blendMode = .whitePremultiplied
        
        largeLineBuffer.load(graphics: graphics, sprite: largeLineSprite)
        largeLineBuffer.blendMode = .whitePremultiplied
        
        smallDotBuffer.load(graphics: graphics, sprite: smallDotSprite)
        smallDotBuffer.blendMode = .whitePremultiplied
        
        largeDotBuffer.load(graphics: graphics, sprite: largeDotSprite)
        largeDotBuffer.blendMode = .whitePremultiplied
    }
    
    func loadComplete() {
        
    }
    
    func update(deltaTime: Float) {
        
    }
    
    func draw3D(renderEncoder: MTLRenderCommandEncoder) {
        
    }
    
    func draw2D(renderEncoder: MTLRenderCommandEncoder) {
        
        var projection = matrix_identity_float4x4
        projection.ortho(width: width,
                         height: height)
        
        
        triangleBuffer.reset()
        triangleBuffer.projectionMatrix = projection
        triangleBuffer.modelViewMatrix = matrix_identity_float4x4
        
        smallLineBuffer.reset()
        smallLineBuffer.projectionMatrix = projection
        smallLineBuffer.modelViewMatrix = matrix_identity_float4x4
        
        largeLineBuffer.reset()
        largeLineBuffer.projectionMatrix = projection
        largeLineBuffer.modelViewMatrix = matrix_identity_float4x4
        
        smallDotBuffer.reset()
        smallDotBuffer.projectionMatrix = projection
        smallDotBuffer.modelViewMatrix = matrix_identity_float4x4
        
        largeDotBuffer.reset()
        largeDotBuffer.projectionMatrix = projection
        largeDotBuffer.modelViewMatrix = matrix_identity_float4x4
        
        switch sceneViewModel.triangulationMode {
            
        case .delauney:
            
            var innerPoints = [SIMD2<Float>]()
            
            for point in sceneViewModel.polygon {
                innerPoints.append(.init(point.x, point.y))
            }
            
            for point in sceneViewModel.innerPoints {
                innerPoints.append(.init(point.x, point.y))
            }
            
            DelauneyTriangulator.shared.triangulate(points: innerPoints)
            
            break
        case .constrainedDelauney:
            
            var innerPoints = [SIMD2<Float>]()
            var hullPoints = [SIMD2<Float>]()
            
            for point in sceneViewModel.polygon {
                hullPoints.append(.init(point.x, point.y))
            }
            
            for point in sceneViewModel.innerPoints {
                innerPoints.append(.init(point.x, point.y))
            }
            
            DelauneyTriangulator.shared.triangulate(points: innerPoints,
                                                                         hull: hullPoints)
            
            break
            
        }
        
        var drawnEdges = Set<DrawEdge>()
        for triangle in DelauneyTriangulator.shared.triangles {
            
            triangleBuffer.add(cornerX1: triangle.point1.x, cornerY1: triangle.point1.y,
                               cornerX2: triangle.point2.x, cornerY2: triangle.point2.y,
                               cornerX3: triangle.point3.x, cornerY3: triangle.point3.y,
                               translation: .zero, scale: 1.0, rotation: 0.0,
                               red: 0.5, green: 0.85, blue: 0.25, alpha: 0.5)
        }
        
        for triangle in DelauneyTriangulator.shared.triangles {
            let drawEdge1A = DrawEdge(point1: triangle.point1, point2: triangle.point2)
            let drawEdge1B = DrawEdge(point1: triangle.point2, point2: triangle.point1)
            
            let drawEdge2A = DrawEdge(point1: triangle.point2, point2: triangle.point3)
            let drawEdge2B = DrawEdge(point1: triangle.point3, point2: triangle.point2)
            
            let drawEdge3A = DrawEdge(point1: triangle.point3, point2: triangle.point1)
            let drawEdge3B = DrawEdge(point1: triangle.point1, point2: triangle.point3)
            
            if !(drawnEdges.contains(drawEdge1A) || drawnEdges.contains(drawEdge1B)) {
                drawnEdges.insert(drawEdge1A)
                smallLineBuffer.add(lineX1: triangle.point1.x, lineY1: triangle.point1.y,
                                    lineX2: triangle.point2.x, lineY2: triangle.point2.y,
                                    lineThickness: smallLineSprite.width2,
                                    translation: .zero, scale: 1.0, rotation: 0.0, red: 0.35, green: 0.35, blue: 0.35, alpha: 0.5)
            }
            
            if !(drawnEdges.contains(drawEdge2A) || drawnEdges.contains(drawEdge2B)) {
                drawnEdges.insert(drawEdge2A)
                smallLineBuffer.add(lineX1: triangle.point2.x, lineY1: triangle.point2.y,
                                    lineX2: triangle.point3.x, lineY2: triangle.point3.y,
                                    lineThickness: smallLineSprite.width2,
                                    translation: .zero, scale: 1.0, rotation: 0.0, red: 0.35, green: 0.35, blue: 0.35, alpha: 0.5)
            }
            
            if !(drawnEdges.contains(drawEdge3A) || drawnEdges.contains(drawEdge3B)) {
                drawnEdges.insert(drawEdge3A)
                smallLineBuffer.add(lineX1: triangle.point3.x, lineY1: triangle.point3.y,
                                    lineX2: triangle.point1.x, lineY2: triangle.point1.y,
                                    lineThickness: smallLineSprite.width2,
                                    translation: .zero, scale: 1.0, rotation: 0.0, red: 0.35, green: 0.35, blue: 0.35, alpha: 0.5)
            }
            
            
            
        }
        
        /*
        for hullPoint in hullPoints {
            DelauneyTriangulator.shared.partsFactory.depositPoint(hullPoint)
        }
        */
        
        
        var index1 = sceneViewModel.polygon.count - 1
        var index2 = 0
        while index2 < sceneViewModel.polygon.count {
            
            let point1 = sceneViewModel.polygon[index1]
            let point2 = sceneViewModel.polygon[index2]
            
            largeLineBuffer.add(lineX1: point1.x,
                                lineY1: point1.y,
                                lineX2: point2.x,
                                lineY2: point2.y,
                                lineThickness: largeLineSprite.width2,
                                translation: .zero, scale: 1.0, rotation: 0.0,
                                red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
            
            if index2 == sceneViewModel.polygon.count - 1 {
                largeDotBuffer.add(translation: .init(x: point2.x, y: point2.y), scale: 1.0, rotation: 0.0, red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            } else if index2 == 0 {
                largeDotBuffer.add(translation: .init(x: point2.x, y: point2.y), scale: 1.0, rotation: 0.0, red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            } else {
                largeDotBuffer.add(translation: .init(x: point2.x, y: point2.y), scale: 0.75, rotation: 0.0, red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
            }
            
            
            index1 = index2
            index2 += 1
        }
        
        var index = 0
        while index < sceneViewModel.innerPoints.count {
            
            let point = sceneViewModel.innerPoints[index]
            
            smallDotBuffer.add(translation: .init(x: point.x, y: point.y),
                               scale: 0.75, rotation: 0.0, red: 0.5, green: 0.25, blue: 1.0, alpha: 0.75)
            
            
            index += 1
        }
        
        /*
        smallLineBuffer.add(lineX1: 300.0, lineY1: 220.0, lineX2: 600.0, lineY2: 800.0, lineThickness: 2.0, translation: .zero, scale: 1.0, rotation: 0.0, red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        smallDotBuffer.add(translation: .init(x: 300.0, y: 200.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        smallDotBuffer.add(translation: .init(x: 600.0, y: 200.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        smallDotBuffer.add(translation: .init(x: 800.0, y: 200.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        

        largeDotBuffer.add(translation: .init(x: 300.0, y: 400.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        largeDotBuffer.add(translation: .init(x: 600.0, y: 500.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        largeDotBuffer.add(translation: .init(x: 800.0, y: 260.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        */
        
        triangleBuffer.cullMode = .none
        triangleBuffer.render(renderEncoder: renderEncoder)
        
        smallLineBuffer.render(renderEncoder: renderEncoder)
        smallDotBuffer.render(renderEncoder: renderEncoder)
        
        largeLineBuffer.render(renderEncoder: renderEncoder)
        largeDotBuffer.render(renderEncoder: renderEncoder)
        
    }
}
