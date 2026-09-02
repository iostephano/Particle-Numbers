//
//  ParticleShader.metal
//  ParticleNumbers
//
//  Created by Stephano Portella on 04/06/25.
//

#include <metal_stdlib>
using namespace metal;

struct Particle {
    float2 position;
    float2 originalPosition;
    float2 targetPosition;
    float4 color;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float  pointSize [[point_size]];
};

vertex VertexOut vertexShader(const device Particle* particles [[buffer(0)]],
                              constant float& pointSize        [[buffer(1)]],
                              uint vid                         [[vertex_id]]) {
    VertexOut out;
    out.position = float4(particles[vid].position, 0.0, 1.0);
    out.color = particles[vid].color;
    out.pointSize = pointSize;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return in.color;
}
