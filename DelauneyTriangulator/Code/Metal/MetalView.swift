//
//  GameView.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/9/23.
//

import UIKit

class MetalView: UIView {
    
    let name: String
    
    required init(width: CGFloat,
                  height: CGFloat,
                  name: String) {
        self.name = name
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: width, height: height))
        print("[++] MetalView {\(name)}")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
    
    deinit {
        print("[--] MetalView {\(name)}")
    }
}
