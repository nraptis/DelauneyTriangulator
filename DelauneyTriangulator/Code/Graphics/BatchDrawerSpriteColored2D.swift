//
//  BatchDrawerSpriteColored2D.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/18/23.
//

import Foundation
import Metal
import simd

class BatchDrawerSpriteColored2D {
    
    private(set) unowned var graphics: Graphics?
    
    var cullMode = MTLCullMode.back
    var samplerState = Graphics.SamplerState.linearClamp
    
    var blendMode = SpriteInstance2D.BlendMode.alpha
    
    var projectionMatrix = matrix_identity_float4x4
    var modelViewMatrix = matrix_identity_float4x4

    var red = Float(1.0)
    var green = Float(1.0)
    var blue = Float(1.0)
    var alpha = Float(1.0)
    
    func load(graphics: Graphics) {
        self.graphics = graphics
    }
    
    private var instances = [SpriteInstance2D]()
    private var queue = [SpriteInstance2D]()
    
    func reset() {
        queue.append(contentsOf: instances)
        instances.removeAll(keepingCapacity: true)
    }
    
    func prepareInstance(_ instance: SpriteInstance2D) {
        instance.blendMode = blendMode
        instance.cullMode = cullMode
        instance.samplerState = samplerState
        instance.projectionMatrix = projectionMatrix
        instance.modelViewMatrix = modelViewMatrix
        instance.red = red
        instance.green = green
        instance.blue = blue
        instance.alpha = alpha
    }
    
    func dequeueInstance() -> SpriteInstance2D {
        if queue.count > 0 {
            let instance = queue[queue.count - 1]
            queue.removeLast()
            prepareInstance(instance)
            instances.append(instance)
            return instance
        }
        
        let instance = SpriteInstance2D()
        instances.append(instance)
        prepareInstance(instance)
        guard let graphics = graphics else {
            print("Fatal Error! Graphics Expected!!!")
            return instance
        }
        
        instance.load(graphics: graphics)
        return instance
    }
    
    func setColor(_ red: Float = 1.0, _ green: Float = 1.0, _ blue: Float = 1.0, _ alpha: Float = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    private var _cornerX: [Float] = [0.0, 0.0, 0.0, 0.0]
    private var _cornerY: [Float] = [0.0, 0.0, 0.0, 0.0]
    func add(sprite: Sprite2D?,
             cornerX1: Float, cornerY1: Float,
             cornerX2: Float, cornerY2: Float,
             cornerX3: Float, cornerY3: Float,
             cornerX4: Float, cornerY4: Float,
             translation: Math.Point, scale: Float, rotation: Float) {
        
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
        
        let instance = dequeueInstance()
        
        instance.sprite = sprite
        
        //print("spofx: \(_cornerX)")
        //print("spofy: \(_cornerY)")
        
        
        
        instance.setX1(_cornerX[0])
        instance.setX2(_cornerX[1])
        instance.setX3(_cornerX[2])
        instance.setX4(_cornerX[3])
        
        instance.setY1(_cornerY[0])
        instance.setY2(_cornerY[1])
        instance.setY3(_cornerY[2])
        instance.setY4(_cornerY[3])
        
        //instance.red = red
        //instance.green = green
        //instance.blue = blue
        //instance.alpha = alpha
        //instance.projectionMatrix = projectionMatrix
        //instance.modelViewMatrix = modelViewMatrix
        
        instance.setTextureCoordRect(sprite)
    }
    
    func add(sprite: Sprite2D?,
             lineX1: Float, lineY1: Float,
             lineX2: Float, lineY2: Float,
             
             lineThickness: Float,
             
             translation: Math.Point, scale: Float, rotation: Float) {
        
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
        
        add(sprite: sprite,
            cornerX1: lineX2 - dirX, cornerY1: lineY2 - dirY,
            cornerX2: lineX2 + dirX, cornerY2: lineY2 + dirY,
            cornerX3: lineX1 - dirX, cornerY3: lineY1 - dirY,
            cornerX4: lineX1 + dirX, cornerY4: lineY1 + dirY,
            translation: translation, scale: scale, rotation: rotation)
        
    }
    
    func add(sprite: Sprite2D?, translation: Math.Point, scale: Float, rotation: Float) {
        
        guard let sprite = sprite else {
            print("IndexTriangleBufferSpriteColored2D => AddTranslateScaleRotate => Missing Sprite")
            return
        }
        
        let width2 = sprite.width2
        let _width2 = -width2
        
        let height2 = sprite.height2
        let _height2 = -height2
        
        let cornerX1 = translation.x + _width2
        let cornerY1 = translation.y + _height2
        
        let cornerX2 = translation.x + width2
        let cornerY2 = translation.y + _height2
        
        let cornerX3 = translation.x + _width2
        let cornerY3 = translation.y + height2
        
        let cornerX4 = translation.x + width2
        let cornerY4 = translation.y + height2
        
        add(sprite: sprite,
            cornerX1: cornerX1, cornerY1: cornerY1,
            cornerX2: cornerX2, cornerY2: cornerY2,
            cornerX3: cornerX3, cornerY3: cornerY3,
            cornerX4: cornerX4, cornerY4: cornerY4,
            translation: .zero, scale: scale, rotation: rotation)
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
        for instance in instances {
            instance.render(renderEncoder: renderEncoder)
        }
        
        
    }
    
    
}
