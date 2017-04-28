//
//  ViewController.swift
//  MetalTutorialPart1
//
//  Created by Chia-Cheng Hsu on 2017/4/25.
//  Copyright © 2017年 Chia-Cheng Hsu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var uiimage: UIImageView!
    @IBOutlet weak var showImage: UIView!
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var queue: MTLCommandQueue!
    var intputBuffer: MTLBuffer!
    var outputBuffer: MTLBuffer!
    var cps: MTLComputePipelineState!
    override func viewDidLoad() {
        super.viewDidLoad()
        initCommon()
        let date = Date()
        let time = date.timeIntervalSince1970
        print("\(time)")
        for _ in 0..<100 {
            computeShader()
        }
        print("\(Date().timeIntervalSince1970 - time)")
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
        metalLayer.framebufferOnly = false
        metalLayer.frame = showImage.layer.frame
//        metalLayer.drawableSize = CGSize(width: 176, height: 144*6)
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
        let bytes = yuvOriginalData.length
        intputBuffer = device.makeBuffer(length: bytes, options: [])
        outputBuffer = device.makeBuffer(length: bytes * 2, options: [])
        let bufferPointer = intputBuffer.contents()
        NSLog("before copy, size: \(bytes)")
        memcpy(bufferPointer, originData, bytes)
        NSLog("after copy")
//        memset(bufferPointer, 0, bytes * MemoryLayout<Float>.size)
        // registerComputerShader
        queue = device.makeCommandQueue()
        let library = device.newDefaultLibrary()
        let kernel = library?.makeFunction(name: "YUYVColorConversion")
        try! cps = device.makeComputePipelineState(function: kernel!)
    }
    
    func computeShader() -> Void {
//        let data = NSData(bytesNoCopy: outputBuffer.contents(), length: outputBuffer.length)
//        print("before compute: \(data))")
        if let drawable = metalLayer.nextDrawable(){
            let commandBuffer = queue.makeCommandBuffer()
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()
            let drawbleWidth = drawable.texture.width,
                drawableHeight = drawable.texture.height,
                threadWidth = 16, threadHeight = 32
            commandEncoder.setComputePipelineState(cps)
            commandEncoder.setBuffer(intputBuffer, offset: 0, at: 1)
//            commandEncoder.setBuffer(outputBuffer, offset: 0, at: 1)
            commandEncoder.setTexture(drawable.texture, at: 0)
            let threadsPerGroup = MTLSizeMake(threadWidth, threadHeight, 1)
            let numThreadGroup = MTLSizeMake(drawbleWidth/threadWidth, drawableHeight/threadHeight , 1)
            commandEncoder.dispatchThreadgroups(numThreadGroup, threadsPerThreadgroup: threadsPerGroup)
            
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
        
//        print("after compute: \(data)")
//        let cgimage = convertRGBToImage(data: data as Data)
//        self.uiimage.image = UIImage(cgImage: cgimage)
    }
    
    func convertRGBToImage(data: Data) -> CGImage {
        guard let provider = CGDataProvider(data: data as CFData) else {
            print("convertRGBToImage: provider error")
            return UIImage(named: "warning")! as! CGImage
        }
        let cgImage: CGImage! = CGImage(width: 176,
                                        height: 144*6,
                                        bitsPerComponent: 8,
                                        bitsPerPixel: 32,
                                        bytesPerRow: 4*176,
                                        space: CGColorSpaceCreateDeviceRGB(),
                                        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                                        provider: provider,
                                        decode: nil,
                                        shouldInterpolate: true,
                                        intent: .defaultIntent)
        return cgImage
    }
}

