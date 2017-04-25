//
//  Shader.metal
//  MetalTutorialPart1
//
//  Created by Chia-Cheng Hsu on 2017/4/25.
//  Copyright © 2017年 Chia-Cheng Hsu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0)]],
                           unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment(){
    return half4(1.0);
}
