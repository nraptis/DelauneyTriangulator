//
//  SpriteInstance2D.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/9/23.
//

import Foundation
import Metal
import simd

class SpriteInstance2D {
    
    enum BlendMode {
        case none
        case alpha
        case additive
        case premultiplied
        
        case whiteNone
        case whiteAlpha
        case whiteAdditive
        case whitePremultiplied
    }
    
    var blendMode = BlendMode.alpha
    
    unowned var sprite: Sprite2D?
    private(set) unowned var graphics: Graphics?
    
    private var uniformsVertex = UniformsSpriteVertex()
    private var uniformsFragment = UniformsSpriteFragment()
    private var uniformsVertexBuffer: MTLBuffer?
    private var uniformsFragmentBuffer: MTLBuffer?
    
    private var vertexBuffer: MTLBuffer?
    private var indexBuffer: MTLBuffer?
    
    private var vertices = [Float](repeating: 0.0, count: 8 + 8)
    private var indices: [UInt16] = [0, 1, 2, 3]
    
    var cullMode = MTLCullMode.back
    var samplerState = Graphics.SamplerState.linearClamp
    
    var isVertexBufferDirty = true
    var isIndexBufferDirty = true
    
    var isUniformsVertexBufferDirty = true
    var isUniformsFragmentBufferDirty = true
    
    func setX1(_ value: Float) {
        if vertices[0] != value {
            vertices[0] = value
            isVertexBufferDirty = true
        }
    }
    func setY1(_ value: Float) {
        if vertices[1] != value {
            vertices[1] = value
            isVertexBufferDirty = true
        }
    }
    func setU1(_ value: Float) {
        if vertices[2] != value {
            vertices[2] = value
            isVertexBufferDirty = true
        }
    }
    func setV1(_ value: Float) {
        if vertices[3] != value {
            vertices[3] = value
            isVertexBufferDirty = true
        }
    }
    
    func setX2(_ value: Float) {
        if vertices[4] != value {
            vertices[4] = value
            isVertexBufferDirty = true
        }
    }
    func setY2(_ value: Float) {
        if vertices[5] != value {
            vertices[5] = value
            isVertexBufferDirty = true
        }
    }
    func setU2(_ value: Float) {
        if vertices[6] != value {
            vertices[6] = value
            isVertexBufferDirty = true
        }
    }
    func setV2(_ value: Float) {
        if vertices[7] != value {
            vertices[7] = value
            isVertexBufferDirty = true
        }
    }
    
    func setX3(_ value: Float) {
        if vertices[8] != value {
            vertices[8] = value
            isVertexBufferDirty = true
        }
    }
    func setY3(_ value: Float) {
        if vertices[9] != value {
            vertices[9] = value
            isVertexBufferDirty = true
        }
    }
    func setU3(_ value: Float) {
        if vertices[10] != value {
            vertices[10] = value
            isVertexBufferDirty = true
        }
    }
    func setV3(_ value: Float) {
        if vertices[11] != value {
            vertices[11] = value
            isVertexBufferDirty = true
        }
    }
    
    func setX4(_ value: Float) {
        if vertices[12] != value {
            vertices[12] = value
            isVertexBufferDirty = true
        }
    }
    func setY4(_ value: Float) {
        if vertices[13] != value {
            vertices[13] = value
            isVertexBufferDirty = true
        }
    }
    func setU4(_ value: Float) {
        if vertices[14] != value {
            vertices[14] = value
            isVertexBufferDirty = true
        }
    }
    func setV4(_ value: Float) {
        if vertices[15] != value {
            vertices[15] = value
            isVertexBufferDirty = true
        }
    }
    
    func setPositionRect(_ sprite: Sprite2D) {
        setX1(sprite.startX)
        setY1(sprite.startY)
        
        setX2(sprite.endX)
        setY2(sprite.startY)
        
        setX3(sprite.startX)
        setY3(sprite.endY)
        
        setX4(sprite.endX)
        setY4(sprite.endY)
    }
    
    func setTextureCoordRect(_ sprite: Sprite2D) {
        setU1(sprite.startU)
        setV1(sprite.startV)
        
        setU2(sprite.endU)
        setV2(sprite.startV)
        
        setU3(sprite.startU)
        setV3(sprite.endV)
        
        setU4(sprite.endU)
        setV4(sprite.endV)
    }
    
    var projectionMatrix: matrix_float4x4 {
        get {
            uniformsVertex.projectionMatrix
        }
        set {
            if uniformsVertex.projectionMatrix != newValue {
                uniformsVertex.projectionMatrix = newValue
                isUniformsVertexBufferDirty = true
            }
        }
    }
    var modelViewMatrix: matrix_float4x4 {
        get { uniformsVertex.modelViewMatrix }
        set {
            if uniformsVertex.modelViewMatrix != newValue {
                uniformsVertex.modelViewMatrix = newValue
                isUniformsVertexBufferDirty = true
            }
        }
    }
    
    var red: Float {
        get { uniformsFragment.red }
        set {
            if uniformsFragment.red != newValue {
                uniformsFragment.red = newValue
                isUniformsFragmentBufferDirty = true
            }
        }
    }
    var green: Float {
        get { uniformsFragment.green }
        set {
            if uniformsFragment.green != newValue {
                uniformsFragment.green = newValue
                isUniformsFragmentBufferDirty = true
            }
        }
    }
    var blue: Float {
        get { uniformsFragment.blue }
        set {
            if uniformsFragment.blue != newValue {
                uniformsFragment.blue = newValue
                isUniformsFragmentBufferDirty = true
            }
        }
    }
    var alpha: Float {
        get { uniformsFragment.alpha }
        set {
            if uniformsFragment.alpha != newValue {
                uniformsFragment.alpha = newValue
                isUniformsFragmentBufferDirty = true
            }
        }
    }
    
    func load(graphics: Graphics) {
        self.graphics = graphics
        uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
        uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        vertexBuffer = graphics.buffer(array: vertices)
        indexBuffer = graphics.buffer(array: indices)
    }
    
    func load(graphics: Graphics,
              sprite: Sprite2D?) {
        
        load(graphics: graphics)
        self.sprite = sprite
        if let sprite = sprite {
            setX1(sprite.startX)
            setY1(sprite.startY)
            setU1(sprite.startU)
            setV1(sprite.startV)
            setX2(sprite.endX)
            setY2(sprite.startY)
            setU2(sprite.endU)
            setV2(sprite.startV)
            setX3(sprite.startX)
            setY3(sprite.endY)
            setU3(sprite.startU)
            setV3(sprite.endV)
            setX4(sprite.endX)
            setY4(sprite.endY)
            setU4(sprite.endU)
            setV4(sprite.endV)
        }
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
        guard let graphics = graphics else { return }
        guard let sprite = sprite else { return }
        guard let texture = sprite.texture else { return }
        
        guard let vertexBuffer = vertexBuffer else { return }
        guard let indexBuffer = indexBuffer else { return }
        
        guard let uniformsVertexBuffer = uniformsVertexBuffer else { return }
        guard let uniformsFragmentBuffer = uniformsFragmentBuffer else { return }
        
        switch blendMode {
        case .none:
            graphics.set(pipelineState: .spriteNodeIndexed2DNoBlending, renderEncoder: renderEncoder)
        case .alpha:
            graphics.set(pipelineState: .spriteNodeIndexed2DAlphaBlending, renderEncoder: renderEncoder)
        case .additive:
            graphics.set(pipelineState: .spriteNodeIndexed2DAdditiveBlending, renderEncoder: renderEncoder)
        case .premultiplied:
            graphics.set(pipelineState: .spriteNodeIndexed2DPremultipliedBlending, renderEncoder: renderEncoder)
        case .whiteNone:
            graphics.set(pipelineState: .spriteNodeWhiteIndexed2DNoBlending, renderEncoder: renderEncoder)
        case .whiteAlpha:
            graphics.set(pipelineState: .spriteNodeWhiteIndexed2DAlphaBlending, renderEncoder: renderEncoder)
        case .whiteAdditive:
            graphics.set(pipelineState: .spriteNodeWhiteIndexed2DAdditiveBlending, renderEncoder: renderEncoder)
        case .whitePremultiplied:
            graphics.set(pipelineState: .spriteNodeWhiteIndexed2DPremultipliedBlending, renderEncoder: renderEncoder)
        }
        
        if isVertexBufferDirty {
            graphics.write(buffer: vertexBuffer, array: vertices)
            isVertexBufferDirty = false
        }
        if isIndexBufferDirty {
            graphics.write(buffer: indexBuffer, array: indices)
            isIndexBufferDirty = false
        }
        if isUniformsVertexBufferDirty {
            graphics.write(buffer: uniformsVertexBuffer, uniform: uniformsVertex)
            isUniformsVertexBufferDirty = false
        }
        if isUniformsFragmentBufferDirty {
            graphics.write(buffer: uniformsFragmentBuffer, uniform: uniformsFragment)
            isUniformsFragmentBufferDirty = false
        }
        
        graphics.setFragmentTexture(texture, renderEncoder: renderEncoder)
        
        graphics.setVertexUniformsBuffer(uniformsVertexBuffer, renderEncoder: renderEncoder)
        graphics.setFragmentUniformsBuffer(uniformsFragmentBuffer, renderEncoder: renderEncoder)
        
        graphics.setVertexDataBuffer(vertexBuffer, renderEncoder: renderEncoder)
        
        graphics.set(samplerState: samplerState, renderEncoder: renderEncoder)
        
        renderEncoder.setCullMode(cullMode)
        
        //print("apr: \(vertices)")
        renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                            indexCount: 4,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
    
    func setFrame(x: Float, y: Float, width: Float, height: Float) {
        setQuad(x1: x,
                y1: y,
                x2: x + width,
                y2: y + height,
                width: width,
                height: height)
    }
    
    func setQuad(x1: Float, y1: Float, x2: Float, y2: Float, width: Float, height: Float) {
        setQuad(x1: x1,
                y1: y1,
                x2: x2,
                y2: y1,
                x3: x1,
                y3: y2,
                x4: x2,
                y4: y2,
                width: width,
                height: height)
    }
    
    func setQuad(x1: Float, y1: Float,
                 x2: Float, y2: Float,
                 x3: Float, y3: Float,
                 x4: Float, y4: Float,
                 width: Float, height: Float) {
        
        setX1(x1)
        setX2(x2)
        setX3(x3)
        setX4(x4)
        setY1(y1)
        setY2(y2)
        setY3(y3)
        setY4(y4)
    }
    
}
