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

class TriangleScene: GraphicsDelegate {
    
    unowned var sceneViewModel: SceneViewModel!
    unowned var graphics: Graphics!
    
    let triangleBuffer = IndexTriangleBufferSpriteColored2D()
    
    let smallLineBuffer = IndexTriangleBufferSpriteColored2D()
    let largeLineBuffer = IndexTriangleBufferSpriteColored2D()
    
    let smallDotBuffer = IndexTriangleBufferSpriteColored2D()
    let largeDotBuffer = IndexTriangleBufferSpriteColored2D()
    
    
    
    let width: Float
    let height: Float
    let width2: Float
    let height2: Float
    
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
        
        //let largeLineBuffer = IndexTriangleBufferSpriteColored2D()
        
        //let smallDotBuffer = IndexTriangleBufferSpriteColored2D()
        //let largeDotBuffer = IndexTriangleBufferSpriteColored2D()
        
    }
    
    func loadComplete() {
        
        //jiggleEngine.loadComplete()
        
    }
    
    func update(deltaTime: Float) {
        
        
        
    }
    
    func draw3D(renderEncoder: MTLRenderCommandEncoder) {
        //jiggleEngine.draw3D(renderEncoder: renderEncoder)
        
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
        
        let point1 = Math.Point(x: 100.0, y: 100.0)
        let point2 = Math.Point(x: 200.0, y: 120.0)
        let point3 = Math.Point(x: 150.0, y: 300.0)
        
        triangleBuffer.add(cornerX1: point1.x, cornerY1: point1.y,
                           cornerX2: point2.x, cornerY2: point2.y,
                           cornerX3: point3.x, cornerY3: point3.y,
                           translation: .zero, scale: 1.0, rotation: 0.0,
                           red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        
        smallLineBuffer.add(lineX1: 300.0, lineY1: 220.0, lineX2: 600.0, lineY2: 800.0, lineThickness: 2.0, translation: .zero, scale: 1.0, rotation: 0.0, red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        
        
        largeLineBuffer.add(lineX1: 100.0, lineY1: 420.0, lineX2: 300.0, lineY2: 400.0, lineThickness: 10.0, translation: .zero, scale: 1.0, rotation: 0.0, red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        
        
        smallDotBuffer.add(translation: .init(x: 300.0, y: 200.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        smallDotBuffer.add(translation: .init(x: 600.0, y: 200.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        smallDotBuffer.add(translation: .init(x: 800.0, y: 200.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        

        largeDotBuffer.add(translation: .init(x: 300.0, y: 400.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        largeDotBuffer.add(translation: .init(x: 600.0, y: 500.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        largeDotBuffer.add(translation: .init(x: 800.0, y: 260.0), scale: 1.0, rotation: 0.0, red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        
        triangleBuffer.render(renderEncoder: renderEncoder)
        
        smallLineBuffer.render(renderEncoder: renderEncoder)
        largeLineBuffer.render(renderEncoder: renderEncoder)
        
        smallDotBuffer.render(renderEncoder: renderEncoder)
        largeDotBuffer.render(renderEncoder: renderEncoder)
        
    }
}
