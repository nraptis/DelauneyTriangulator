//
//  IndexTriangleBufferSpriteColored2D.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/14/23.
//

import Foundation
import Metal
import simd

struct VertexSpriteColored2D {
    var x: Float = 0.0
    var y: Float = 0.0
    var u: Float = 0.0
    var v: Float = 0.0
    var r: Float = 1.0
    var g: Float = 1.0
    var b: Float = 1.0
    var a: Float = 1.0
    
    init(x: Float, y: Float,
         u: Float, v: Float,
         r: Float, g: Float, b: Float, a: Float) {
        self.x = x; self.y = y
        self.u = u; self.v = v
        self.r = r; self.g = g; self.b = b; self.a = a
    }
    
    init() {
        
    }
}

class IndexTriangleBufferSpriteColored2D {
    
    private(set) unowned var sprite: Sprite2D?
    private(set) unowned var graphics: Graphics?
    
    private(set) var vertices = Array<VertexSpriteColored2D>()
    private(set) var verticesCount = 0
    private(set) var verticesSize = 0
    
    private(set) var indices = Array<UInt16>()
    private(set) var indicesCount = 0
    private(set) var indicesSize = 0
    
    private var vertexBufferLength = 0
    private var indexBufferLength = 0
    
    private var uniformsVertex = UniformsSpriteNodeIndexedVertex()
    private var uniformsFragment = UniformsSpriteNodeIndexedFragment()
    
    private(set) var indexBuffer: MTLBuffer!
    private(set) var vertexBuffer: MTLBuffer!
    private(set) var uniformsVertexBuffer: MTLBuffer!
    private(set) var uniformsFragmentBuffer: MTLBuffer!
    
    var isVertexBufferDirty = true
    var isIndexBufferDirty = true
    var isUniformsVertexBufferDirty = true
    var isUniformsFragmentBufferDirty = true
    
    var primitiveType = MTLPrimitiveType.triangle
    var cullMode = MTLCullMode.back
    var samplerState = Graphics.SamplerState.linearClamp
    
    var projectionMatrix: matrix_float4x4 {
        get {
            uniformsVertex.projectionMatrix
        }
        set {
            uniformsVertex.projectionMatrix = newValue
            isUniformsVertexBufferDirty = true
        }
    }
    var modelViewMatrix: matrix_float4x4 {
        get { uniformsVertex.modelViewMatrix }
        set {
            uniformsVertex.modelViewMatrix = newValue
            isUniformsVertexBufferDirty = true
        }
    }
    
    var red: Float {
        get { uniformsFragment.red }
        set {
            uniformsFragment.red = newValue
            isUniformsFragmentBufferDirty = true
        }
    }
    var green: Float {
        get { uniformsFragment.green }
        set {
            uniformsFragment.green = newValue
            isUniformsFragmentBufferDirty = true
        }
    }
    var blue: Float {
        get { uniformsFragment.blue }
        set {
            uniformsFragment.blue = newValue
            isUniformsFragmentBufferDirty = true
        }
    }
    var alpha: Float {
        get { uniformsFragment.alpha }
        set {
            uniformsFragment.alpha = newValue
            isUniformsFragmentBufferDirty = true
        }
    }
    
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
    
    
    func load(graphics: Graphics,
              sprite: Sprite2D?) {
        
        self.graphics = graphics
        self.sprite = sprite
        
        projectionMatrix.ortho(width: graphics.width, height: graphics.height)
        
        uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
        uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        
        isVertexBufferDirty = true
        isIndexBufferDirty = true
        isUniformsVertexBufferDirty = true
        isUniformsFragmentBufferDirty = true
    }
    
    func reset() {
        verticesCount = 0
        indicesCount = 0
        isVertexBufferDirty = true
        isIndexBufferDirty = true
    }
    
    func add(vertex: VertexSpriteColored2D) {
        if verticesCount >= verticesSize {
            verticesSize = verticesCount + (verticesCount / 2) + 1
            vertices.reserveCapacity(verticesSize)
            while vertices.count < verticesSize {
                vertices.append(.init(x: 0.0, y: 0.0,
                                      u: 0.0, v: 0.0,
                                      r: 1.0, g: 1.0, b: 1.0, a: 1.0))
            }
        }
        vertices[verticesCount] = vertex
        verticesCount += 1
        isVertexBufferDirty = true
    }
    
    func add(index: UInt16) {
        if indicesCount >= indicesSize {
            indicesSize = indicesCount + (indicesCount / 2) + 1
            indices.reserveCapacity(indicesSize)
            
            while indices.count < indicesSize {
                indices.append(0)
            }
        }
        indices[indicesCount] = index
        indicesCount += 1
        isIndexBufferDirty = true
    }
    
    func add(_ index1: UInt16, _ index2: UInt16, _ index3: UInt16) {
        add(index: index1)
        add(index: index2)
        add(index: index3)
    }
    
    private var _cornerX: [Float] = [0.0, 0.0, 0.0, 0.0]
    private var _cornerY: [Float] = [0.0, 0.0, 0.0, 0.0]
    
    func add(cornerX1: Float, cornerY1: Float,
             cornerX2: Float, cornerY2: Float,
             cornerX3: Float, cornerY3: Float,
             cornerX4: Float, cornerY4: Float,
             
             translation: Math.Point, scale: Float, rotation: Float,
             red: Float, green: Float, blue: Float, alpha: Float) {
        
        guard let sprite = sprite else {
            print("IndexTriangleBufferSpriteColored2D => AddQuad => Missing Sprite")
            return
        }
        
        _cornerX[0] = cornerX1; _cornerY[0] = cornerY1
        _cornerX[1] = cornerX2; _cornerY[1] = cornerY2
        _cornerX[2] = cornerX3; _cornerY[2] = cornerY3
        _cornerX[3] = cornerX4; _cornerY[3] = cornerY4
        
        if rotation != 0.0 {
            var cornerIndex = 0
            while cornerIndex < 4 {
                
                var x = _cornerX[cornerIndex]
                var y = _cornerY[cornerIndex]
                
                var dist = x * x + y * y
                if dist > Math.epsilon {
                    dist = sqrtf(Float(dist))
                    x /= dist
                    y /= dist
                }
                
                if scale != 1.0 {
                    dist *= scale
                }
                
                let pivotRotation = rotation - atan2f(-x, -y)
                x = sinf(Float(pivotRotation)) * dist
                y = -cosf(Float(pivotRotation)) * dist
                
                _cornerX[cornerIndex] = x
                _cornerY[cornerIndex] = y
                
                cornerIndex += 1
            }
        } else if scale != 1.0 {
            var cornerIndex = 0
            while cornerIndex < 4 {
                _cornerX[cornerIndex] *= scale
                _cornerY[cornerIndex] *= scale
                cornerIndex += 1
            }
        }
        //
        if translation.x != 0 || translation.y != 0 {
            var cornerIndex = 0
            while cornerIndex < 4 {
                _cornerX[cornerIndex] += translation.x
                _cornerY[cornerIndex] += translation.y
                cornerIndex += 1
            }
        }
        
        //print("epox: \(_cornerX)")
        //print("epoy: \(_cornerY)")
        
        
        //
        let index1 = UInt16(verticesCount)
        let index2 = index1 + 1
        let index3 = index2 + 1
        let index4 = index3 + 1
        //
        add(index1, index2, index3)
        add(index3, index2, index4)
        //
        add(vertex: VertexSpriteColored2D.init(x: _cornerX[0], y: _cornerY[0],
                                               u: sprite.startU, v: sprite.startV,
                                               r: red, g: green, b: blue, a: alpha))
        add(vertex: VertexSpriteColored2D.init(x: _cornerX[1], y: _cornerY[1],
                                               u: sprite.endU, v: sprite.startV,
                                               r: red, g: green, b: blue, a: alpha))
        add(vertex: VertexSpriteColored2D.init(x: _cornerX[2], y: _cornerY[2],
                                               u: sprite.startU, v: sprite.endV,
                                               r: red, g: green, b: blue, a: alpha))
        add(vertex: VertexSpriteColored2D.init(x: _cornerX[3], y: _cornerY[3],
                                               u: sprite.endU, v: sprite.endV,
                                               r: red, g: green, b: blue, a: alpha))
        
    }
    
    
    func add(cornerX1: Float, cornerY1: Float,
             cornerX2: Float, cornerY2: Float,
             cornerX3: Float, cornerY3: Float,
             translation: Math.Point, scale: Float, rotation: Float,
             red: Float, green: Float, blue: Float, alpha: Float) {
        
        guard let sprite = sprite else {
            print("IndexTriangleBufferSpriteColored2D => AddQuad => Missing Sprite")
            return
        }
        
        _cornerX[0] = cornerX1; _cornerY[0] = cornerY1
        _cornerX[1] = cornerX2; _cornerY[1] = cornerY2
        _cornerX[2] = cornerX3; _cornerY[2] = cornerY3
        
        if rotation != 0.0 {
            var cornerIndex = 0
            while cornerIndex < 3 {
                
                var x = _cornerX[cornerIndex]
                var y = _cornerY[cornerIndex]
                
                var dist = x * x + y * y
                if dist > Math.epsilon {
                    dist = sqrtf(Float(dist))
                    x /= dist
                    y /= dist
                }
                
                if scale != 1.0 {
                    dist *= scale
                }
                
                let pivotRotation = rotation - atan2f(-x, -y)
                x = sinf(Float(pivotRotation)) * dist
                y = -cosf(Float(pivotRotation)) * dist
                
                _cornerX[cornerIndex] = x
                _cornerY[cornerIndex] = y
                
                cornerIndex += 1
            }
        } else if scale != 1.0 {
            var cornerIndex = 0
            while cornerIndex < 4 {
                _cornerX[cornerIndex] *= scale
                _cornerY[cornerIndex] *= scale
                cornerIndex += 1
            }
        }
        //
        if translation.x != 0 || translation.y != 0 {
            var cornerIndex = 0
            while cornerIndex < 4 {
                _cornerX[cornerIndex] += translation.x
                _cornerY[cornerIndex] += translation.y
                cornerIndex += 1
            }
        }
        
        //print("epox: \(_cornerX)")
        //print("epoy: \(_cornerY)")
        
        
        //
        let index1 = UInt16(verticesCount)
        let index2 = index1 + 1
        let index3 = index2 + 1
        
        //
        add(index1, index2, index3)
        //
        add(vertex: VertexSpriteColored2D.init(x: _cornerX[0], y: _cornerY[0],
                                               u: sprite.startU, v: sprite.startV,
                                               r: red, g: green, b: blue, a: alpha))
        add(vertex: VertexSpriteColored2D.init(x: _cornerX[1], y: _cornerY[1],
                                               u: sprite.endU, v: sprite.startV,
                                               r: red, g: green, b: blue, a: alpha))
        add(vertex: VertexSpriteColored2D.init(x: _cornerX[2], y: _cornerY[2],
                                               u: sprite.startU, v: sprite.endV,
                                               r: red, g: green, b: blue, a: alpha))
    }
    
    func add(lineX1: Float, lineY1: Float,
             lineX2: Float, lineY2: Float,
             
             lineThickness: Float,
             
             translation: Math.Point, scale: Float, rotation: Float,
             red: Float, green: Float, blue: Float, alpha: Float) {
        
        var dirX = lineX2 - lineX1
        var dirY = lineY2 - lineY1
        var length = dirX * dirX + dirY * dirY
        if length <= Math.epsilon { return }
        
        let thickness = lineThickness * 0.5
        length = sqrtf(length)
        dirX /= length
        dirY /= length
        
        let hold = dirX
        dirX = dirY * (-thickness)
        dirY = hold * thickness
        
        add(cornerX1: lineX2 - dirX, cornerY1: lineY2 - dirY,
            cornerX2: lineX2 + dirX, cornerY2: lineY2 + dirY,
            cornerX3: lineX1 - dirX, cornerY3: lineY1 - dirY,
            cornerX4: lineX1 + dirX, cornerY4: lineY1 + dirY,
            translation: translation, scale: scale, rotation: rotation,
            red: red, green: green, blue: blue, alpha: alpha)
        
    }
    
    func add(translation: Math.Point, scale: Float, rotation: Float,
             red: Float, green: Float, blue: Float, alpha: Float) {
        
        guard let sprite = sprite else {
            print("IndexTriangleBufferSpriteColored2D => AddTranslateScaleRotate => Missing Sprite")
            return
        }
        
        let width2 = sprite.width2
        let _width2 = -width2
        
        let height2 = sprite.height2
        let _height2 = -height2
        
        let cornerX1 = _width2
        let cornerY1 = _height2
        
        let cornerX2 = width2
        let cornerY2 = _height2
        
        let cornerX3 = _width2
        let cornerY3 = height2
        
        let cornerX4 = width2
        let cornerY4 = height2
        
        add(cornerX1: cornerX1, cornerY1: cornerY1,
            cornerX2: cornerX2, cornerY2: cornerY2,
            cornerX3: cornerX3, cornerY3: cornerY3,
            cornerX4: cornerX4, cornerY4: cornerY4,
            translation: translation, scale: scale, rotation: rotation,
            red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
        guard let graphics = graphics else {
            return
        }
        
        guard indicesCount > 0 else {
            return
        }
        
        guard verticesCount > 0 else {
            return
        }
        
        guard let sprite = sprite else {
            print("IndexTriangleBufferSpriteColored2D => Render => Missing Sprite")
            return
        }
        
        guard let texture = sprite.texture else {
            print("IndexTriangleBufferSpriteColored2D => Render => Sprite Missing Texture")
            return
        }
        
        guard let uniformsVertexBuffer = uniformsVertexBuffer else {
            print("IndexTriangleBufferSpriteColored2D => Render => Sprite Missing Uniforms Vertex Buffer")
            return
        }
        
        guard let uniformsFragmentBuffer = uniformsFragmentBuffer else {
            print("IndexTriangleBufferSpriteColored2D => Render => Sprite Missing Uniforms Fragment Buffer")
            return
        }
        
        if isVertexBufferDirty {
            writeVertexBuffer()
        }
        
        if isIndexBufferDirty {
            writeIndexBuffer()
        }
        
        guard let vertexBuffer = vertexBuffer else {
            print("IndexTriangleBufferSpriteColored2D => Render => Sprite Missing Vertex Buffer")
            return
        }
        
        guard let indexBuffer = indexBuffer else {
            print("IndexTriangleBufferSpriteColored2D => Render => Sprite Missing Index Buffer")
            return
        }
        
        if isUniformsVertexBufferDirty {
            graphics.write(buffer: uniformsVertexBuffer, uniform: uniformsVertex)
            isUniformsVertexBufferDirty = false
        }
        if isUniformsFragmentBufferDirty {
            graphics.write(buffer: uniformsFragmentBuffer, uniform: uniformsFragment)
            isUniformsFragmentBufferDirty = false
        }
        
        switch blendMode {
        case .none:
            graphics.set(pipelineState: .spriteNodeColoredIndexed2DNoBlending, renderEncoder: renderEncoder)
        case .alpha:
            graphics.set(pipelineState: .spriteNodeColoredIndexed2DAlphaBlending, renderEncoder: renderEncoder)
        case .additive:
            graphics.set(pipelineState: .spriteNodeColoredIndexed2DAdditiveBlending, renderEncoder: renderEncoder)
        case .premultiplied:
            graphics.set(pipelineState: .spriteNodeColoredIndexed2DPremultipliedBlending, renderEncoder: renderEncoder)
        case .whiteNone:
            graphics.set(pipelineState: .spriteNodeColoredWhiteIndexed2DNoBlending, renderEncoder: renderEncoder)
        case .whiteAlpha:
            graphics.set(pipelineState: .spriteNodeColoredWhiteIndexed2DAlphaBlending, renderEncoder: renderEncoder)
        case .whiteAdditive:
            graphics.set(pipelineState: .spriteNodeColoredWhiteIndexed2DAdditiveBlending, renderEncoder: renderEncoder)
        case .whitePremultiplied:
            graphics.set(pipelineState: .spriteNodeColoredWhiteIndexed2DPremultipliedBlending, renderEncoder: renderEncoder)
        }
        
        graphics.setVertexDataBuffer(vertexBuffer, renderEncoder: renderEncoder)
        
        graphics.setVertexUniformsBuffer(uniformsVertexBuffer, renderEncoder: renderEncoder)
        graphics.setFragmentUniformsBuffer(uniformsFragmentBuffer, renderEncoder: renderEncoder)
        
        graphics.setFragmentTexture(texture, renderEncoder: renderEncoder)
        
        graphics.set(samplerState: samplerState, renderEncoder: renderEncoder)
        
        renderEncoder.setCullMode(cullMode)
        
        renderEncoder.drawIndexedPrimitives(type: primitiveType,
                                            indexCount: indicesCount,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
    }
    
    func writeVertexBuffer() {
        guard let graphics = graphics else { return }
        
        isVertexBufferDirty = false
        
        let length = MemoryLayout<VertexSpriteColored2D>.size * verticesCount
        guard length > 0 else {
            vertexBufferLength = 0
            return
        }
        
        if vertexBuffer !== nil {
            if length > vertexBufferLength {
                vertexBuffer = nil
                vertexBufferLength = MemoryLayout<VertexSpriteColored2D>.size * verticesSize
                vertexBuffer = graphics.metalDevice.makeBuffer(bytes: vertices, length: vertexBufferLength)
            } else {
                vertexBuffer.contents().copyMemory(from: vertices, byteCount: length)
            }
        } else {
            vertexBufferLength = MemoryLayout<VertexSpriteColored2D>.size * verticesSize
            vertexBuffer = graphics.metalDevice.makeBuffer(bytes: vertices, length: vertexBufferLength)
        }
    }
    
    func writeIndexBuffer() {
        guard let graphics = graphics else { return }
        
        isIndexBufferDirty = false
        
        let length = MemoryLayout<UInt16>.size * indicesCount
        guard length > 0 else {
            indexBufferLength = 0
            return
        }
        
        if indexBuffer !== nil {
            if length > indexBufferLength {
                indexBuffer = nil
                indexBufferLength = MemoryLayout<UInt16>.size * indicesSize
                indexBuffer = graphics.metalDevice.makeBuffer(bytes: indices, length: indexBufferLength)
            } else {
                indexBuffer.contents().copyMemory(from: indices, byteCount: length)
            }
        } else {
            indexBufferLength = MemoryLayout<UInt16>.size * indicesSize
            indexBuffer = graphics.metalDevice.makeBuffer(bytes: indices, length: indexBufferLength)
        }
    }
}
