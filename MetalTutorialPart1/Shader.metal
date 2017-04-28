//
//  Shader.metal
//  MetalTutorialPart1
//
//  Created by Chia-Cheng Hsu on 2017/4/25.
//  Copyright © 2017年 Chia-Cheng Hsu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
//TODO: 176*144 is the width/height for testing
#define IMAGE_WIDTH 176
#define IMAGE_HEIGHT 144*6

struct YUYVIinput{
    uint y1;
    uint u;
    uint y2;
    uint v;
};

vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0)]],
                           unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment(){
    return half4(1.0);
}

kernel void YUYVColorConversion(texture2d<half, access::write> outputImage [[texture(0)]],
                                const constant YUYVIinput *inputUInt [[buffer(1)]],
                                const uint2 gid [[thread_position_in_grid]],
                                const uint2 tgPos [[threadgroup_position_in_grid]],
                                const uint2 tPerTg [[ threads_per_threadgroup]],
                                const uint2 tPos [[thread_position_in_threadgroup]]){
    uint2 position = tgPos * tPerTg + tPos;
    
    float3 colorOffset = float3( 0, -0.5, -0.5);
    float3x3 colorMatrix = float3x3(float3(1.000,  0.001,  1.402),
                                    float3(1.000, -0.344, -0.714),
                                    float3(1.000,  1.772,  0.001));
    uint serialPosition = uint(18455);
    float u = float(inputUInt[serialPosition].u)/255.0f,
          v = float(inputUInt[serialPosition].v)/255.0f,
          y = 0.0f;
    if ((serialPosition%2) == 0){
        y = float(inputUInt[serialPosition].y1)/255.0f;
    }else {
        y = float(inputUInt[serialPosition].y2)/255.0;
    }
    
    float3 rgb = colorMatrix * (float3(y, u, v) + colorOffset);
//    if ((serialPosition%2) == 0){
//        rgb = float3(0.2, 0.8, 0.15);
//    }else {
//        rgb = float3(0.8, 0.2, 0.15);
//    }
//    half4 outputRGB = half4(rgb.r, rgb.g, rgb.b, 1.0);
    half4 outputRGB = half4(half3(1.0), 1.0f);

    outputImage.write(outputRGB, gid);
}

//kernel void YCbCrColoerConversion(texture2d<float, access:: read> yTexture [[texture(0)]],
//                                  texture2d<float, access:: read> cbcrTexture [[texture(1)]],
//                                  texture2d<float, access:: write> outTexture [[texture(2)]],
//                                  uint2 gid [[thread_position_in_grid]]){
//    float3 colorOffset = float3( -(16.0/255.0), -0.5, -0.5);
//    float3x3 colorMatrix = float3x3(float3(1.164,  1.164, 1.164),
//                                    float3(0.000, -0.392, 2.017),
//                                    float3(1.596, -0.813, 0.000));
//    uint2 cbcrCoordinates = uint2(gid.x/2, gid.y/2);
//    float y = yTexture.read(gid).r;
//    float2 cbcr = cbcrTexture.read(cbcrCoordinates).rg;
//    float3 ycbcr = float3(y, cbcr);
//    float3 rgb = colorMatrix * (ycbcr + colorOffset);
//    outTexture.write(float4(float3(rgb), 1.0), gid);
//}
