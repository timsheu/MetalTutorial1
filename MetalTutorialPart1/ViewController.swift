//
//  ViewController.swift
//  MetalTutorialPart1
//
//  Created by Chia-Cheng Hsu on 2017/4/25.
//  Copyright © 2017年 Chia-Cheng Hsu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var showImage: UIView!
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var vertexData: [Float] = [0.0,  1.0, 0.0,
                               1.0,  0.0, 0.0,
                               0.0, -1.0, 0.0,
                              -1.0,  0.0, 0.0,
                               0.0,  1.0, 0.0]
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    var value = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = showImage.layer.frame
        view.layer.addSublayer(metalLayer)
        
        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func render() -> Void {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: value/255.0, blue: 5.0/255.0, alpha: 1.0)
        value += 1.0
        value.formTruncatingRemainder(dividingBy: 255.0)
//        vertexData[0] = Float(value)
//        vertexData[3] = -Float(value)
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: 5)
        renderEncoder.endEncoding()
        
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func gameloop() -> Void {
        autoreleasepool {
            self.render()
        }
    }
}

