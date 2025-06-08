//
//  ParticleShader.metal
//  Particle Numbers
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
                              uint vid [[vertex_id]]) {
    VertexOut out;
    out.position = float4(particles[vid].position, 0.0, 1.0);
    out.color = particles[vid].color;
    out.pointSize = 4.0;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return in.color;
}
