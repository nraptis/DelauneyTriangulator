//
//  Sprite2D.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

import Foundation
import Metal

class Sprite2D {
    
    var texture: MTLTexture?
    
    var width: Float = 0.0
    var width2: Float = 0.0
    
    var height: Float = 0.0
    var height2: Float = 0.0
    
    var scaleFactor: Float = 1.0
    
    //var positions: [Float] = [-64.0, -64.0, 64.0, -64.0, -64.0, 64.0, 64.0, 64.0]
    //var textureCoords: [Float] = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]
    //var indices: [UInt16] = [0, 1, 2, 2, 1, 3]
    var startX = Float(-64.0)
    var startY = Float(-64.0)
    var endX = Float(64.0)
    var endY = Float(64.0)
    
    var startU = Float(0.0)
    var startV = Float(0.0)
    var endU = Float(1.0)
    var endV = Float(1.0)
    
    init() {
        
    }
    
    func loadScaled(graphics: Graphics, name: String, `extension`: String) {
        let texture = graphics.loadTextureScaled(name: name,
                                                 extension: `extension`)
        load(graphics: graphics,
             texture: texture,
             scaleFactor: graphics.scaleFactor)
    }
    
    func load(graphics: Graphics, texture: MTLTexture?, scaleFactor: Float) {
        if let texture = texture {
            self.texture = texture
            self.scaleFactor = scaleFactor
            
            width = Float(texture.width)
            height = Float(texture.width)
            
            if scaleFactor > 1.0 {
                width = Float(Int((width / scaleFactor) + 0.5))
                height = Float(Int((height / scaleFactor) + 0.5))
            }
            
            width2 = Float(Int((width * 0.5) + 0.5))
            height2 = Float(Int((height * 0.5) + 0.5))
            let _width_2 = -(width2)
            let _height_2 = -(height2)
            
            startX = _width_2
            startY = _height_2
            endX = width2
            endY = height2
            
            startU = 0.0
            startV = 0.0
            endU = 1.0
            endV = 1.0

        } else {
            self.texture = nil
            width = 0.0
            height = 0.0
            width2 = 0.0
            height2 = 0.0
            self.scaleFactor = 1.0
        }
    }
    
    func setFrame(x: Float, y: Float, width: Float, height: Float) {
        startX = x
        startY = y
        endX = (x + width)
        endY = (y + height)
    }
}

