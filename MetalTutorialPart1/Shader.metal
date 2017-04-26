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
#define IMAGE_HEIGHT 144

struct Uniforms{
    float array[IMAGE_WIDTH*IMAGE_HEIGHT*6];
};

vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0)]],
                           unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment(){
    return half4(1.0);
}

kernel void YCbCrColoerConversion(texture2d<uint, access:: read> input [[texture(0)]],
                                  texture2d<uint, access:: write> output [[texture(1)]],
                                  uint2 gid [[thread_position_in_grid]]){
    
}

kernel void YCbCrColoerConversion(texture2d<float, access:: read> yTexture [[texture(0)]],
                                  texture2d<float, access:: read> cbcrTexture [[texture(1)]],
                                  texture2d<float, access:: write> outTexture [[texture(2)]],
                                  uint2 gid [[thread_position_in_grid]]){
    float3 colorOffset = float3( -(16.0/255.0), -0.5, -0.5);
    float3x3 colorMatrix = float3x3(float3(1.164,  1.164, 1.164),
                                    float3(0.000, -0.392, 2.017),
                                    float3(1.596, -0.813, 0.000));
    uint2 cbcrCoordinates = uint2(gid.x/2, gid.y/2);
    float y = yTexture.read(gid).r;
    float2 cbcr = cbcrTexture.read(cbcrCoordinates).rg;
    float3 ycbcr = float3(y, cbcr);
    float3 rgb = colorMatrix * (ycbcr + colorOffset);
    outTexture.write(float4(float3(rgb), 1.0), gid);
}
