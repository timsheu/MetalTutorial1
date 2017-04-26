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
    var queue: MTLCommandQueue!
    var uniform_buffer: MTLBuffer!
    var cps: MTLComputePipelineState!
    override func viewDidLoad() {
        super.viewDidLoad()
        initCommon()
//        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
//        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func render() -> Void {
    }
    
    func gameloop() -> Void {
        autoreleasepool {
            self.render()
        }
    }
    
    func initCommon() -> Void {
        if device == nil {
            device = MTLCreateSystemDefaultDevice()
        }
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = showImage.layer.frame
        view.layer.addSublayer(metalLayer)
        guard let yuvPath = Bundle.main.path(forResource: "tulips_yuyv422_prog_packed_qcif", ofType: "yuv") else { return }
            //            setDebugText(string: "\(TAG), testYUV, yuvPath: \(yuvPath)")
        guard let yuvOriginalData = NSData.init(contentsOfFile: yuvPath) else {
            NSLog("testYUV: get test yuv data failed")
            return
        }
        let originData = yuvOriginalData.bytes
        //createUniformBuffer
//        let bytesPerPixel = 4 * MemoryLayout<Float>.size
        let bytes = 176 * 144 * 6 * 2
        uniform_buffer = device.makeBuffer(length: bytes, options: [])
        let bufferPointer = uniform_buffer.contents()
        NSLog("before copy")
        memcpy(bufferPointer, originData, bytes)
        NSLog("after copy")
//        memset(bufferPointer, 0, bytes * MemoryLayout<Float>.size)
        // registerComputerShader
        queue = device.makeCommandQueue()
        let library = device.newDefaultLibrary()
        let kernel = library?.makeFunction(name: "YCbCrColoerConversion")
        try! cps = device.makeComputePipelineState(function: kernel!)
    }
    
    func computeShader() -> Void {
        if let drawable = metalLayer.nextDrawable(){
            let commandBuffer = queue.makeCommandBuffer()
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()
            commandEncoder.setComputePipelineState(cps)
            commandEncoder.setTexture(drawable.texture, at: 0)
            commandEncoder.setBuffer(uniform_buffer, offset: 0, at: 1)
            let threadGroupCount = MTLSizeMake(8, 8, 1)
            let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height, threadGroupCount.height)
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

