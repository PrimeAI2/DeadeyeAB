#include <metal_stdlib>
using namespace metal;

// RGBA8Unorm textures should be declared with <float, ...> so .read/.write use float4 in [0,1].
kernel void rockgameRadar(
    texture2d<float, access::read>  curTex   [[texture(0)]],
    texture2d<float, access::read>  lastTex  [[texture(1)]],
    texture2d<float, access::write> outTex   [[texture(2)]],
    constant int*                   constants[[buffer(0)]],
    uint2                           gid      [[thread_position_in_grid]]
){
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;

    float4 cur = float4(0.0);
    if (gid.x < curTex.get_width() && gid.y < curTex.get_height()) {
        cur = curTex.read(gid);
    }

    int pitY     = constants ? constants[0] : 0;
    int uiTimerY = constants ? constants[1] : 0;
    int uiScoreY = constants ? constants[2] : 0;

    (void)uiScoreY; // not used yet

    float4 out = cur;

    // Desaturate UI timer region
    if (gid.y < (uint)uiTimerY) {
        float gray = (cur.r + cur.g + cur.b) / 3.0f;
        out = float4(gray, gray, gray, 1.0f);
    }

    // Emphasize active radar band
    if (gid.y >= (uint)uiTimerY && gid.y < (uint)pitY) {
        out.g = min(1.0f, out.g + 0.12f);
    }

    // Darken below the destroy pit
    if (gid.y >= (uint)pitY) {
        out = float4(0.04f, 0.04f, 0.04f, 1.0f);
    }

    outTex.write(out, gid);
}
