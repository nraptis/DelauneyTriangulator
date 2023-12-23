//
//  MetalViewController.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/10/23.
//

import UIKit

class MetalViewController: UIViewController {
    
    let delegate: GraphicsDelegate
    let graphics: Graphics
    let metalEngine: MetalEngine
    let metalPipeline: MetalPipeline
    let metalLayer: CAMetalLayer
    let name: String
    
    var timer: CADisplayLink?
    
    let metalView: MetalView
    required init(delegate: GraphicsDelegate,
                  width: Float,
                  height: Float,
                  name: String) {
        
        
        let _metalView = MetalView(width: CGFloat(Int(width + 0.5)),
                                   height: CGFloat(Int(height + 0.5)),
                                   name: name)
        let _metalLayer = _metalView.layer as! CAMetalLayer
        let _metalEngine = MetalEngine(metalLayer: _metalLayer,
                                       width: width,
                                       height: height,
                                       name: name)
        let _metalPipeline = MetalPipeline(metalEngine: _metalEngine,
                                           name: name)
        let _graphics = Graphics(width: width,
                                 height: height,
                                 scaleFactor: Float(Int(_metalLayer.contentsScale + 0.5)),
                                 name: name)
        
        _metalEngine.graphics = _graphics
        _metalEngine.delegate = delegate
        
        _graphics.metalEngine = _metalEngine
        _graphics.metalPipeline = _metalPipeline
        _graphics.metalDevice = _metalEngine.metalDevice
        //_graphics.scaleFactor = _metalEngine.scale
        _graphics.metalView = _metalView
        
        delegate.graphics = _graphics
        
        self.delegate = delegate
        self.metalView = _metalView
        self.metalLayer = _metalLayer
        self.metalEngine = _metalEngine
        self.metalPipeline = _metalPipeline
        self.graphics = _graphics
        self.name = name
        
        super.init(nibName: nil,
                   bundle: nil)
        
        print("[++] MetalViewController {\(name)} \( [self.classForCoder] )")
    }
    
    deinit {
        print("[--] MetalViewController {\(name)} \( [self.classForCoder] )")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = metalView
    }
    
    func load() {
        
        delegate.initialize()
        
        metalEngine.load()
        metalPipeline.load()
        
        delegate.load()
        
        timer?.invalidate()
        timer = CADisplayLink(target: self, selector: #selector(drawloop))
        if let timer = timer {
            timer.add(to: RunLoop.main, forMode: .default)
        }
    }
    
    func loadComplete() {
        delegate.loadComplete()
    }
    
    private var previousTimeStamp: CFTimeInterval?
    @objc func drawloop() {
        if let timer = timer {
            var time = 0.0
            if let previousTimeStamp = previousTimeStamp {
                time = timer.timestamp - previousTimeStamp
            }
            update(deltaTime: Float(time))
            metalEngine.draw()
            previousTimeStamp = timer.timestamp
        }
    }
    
    func update(deltaTime: Float) {
        delegate.update(deltaTime: deltaTime)
    }
    
}
