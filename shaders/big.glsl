// Author: mcxsic
// Title: Big (codevember 2019)

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

#define COLOR_1 vec4(70.0, 106.0, 130.0, 255.0) / 255.0
#define COLOR_2 vec4(56.0, 81.0, 100.0, 255.0) / 255.0
#define COLOR_3 vec4(44.0, 62.0, 71.0, 255.0) / 255.0
#define COLOR_4 vec4(39.0, 55.0, 63.0, 255.0) / 255.0
#define COLOR_5 vec4(57.0, 34.0, 64.0, 255.0) / 255.0
#define COLOR_6 vec4(12.0, 11.0, 14.0, 255.0) / 255.0
#define SMOOTH 0.002

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_buffer0;

mat2 rotate2d(in float angle) {
    return mat2(cos(angle), - sin(angle), sin(angle), cos(angle));
}

// The Book Of Shaders implementation (https://thebookofshaders.com/11/)
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise(in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
    (c - a) * u.y * (1.0 - u.x) +
    (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

// The Book Of Shaders implementation (https://thebookofshaders.com/11/)
float fbm(in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(0.880, 0.530);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
    - sin(0.5), cos(0.50));
    for(int i = 0; i < NUM_OCTAVES; ++ i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

vec2 normalizedCoordinates(vec2 pixelCoord, vec2 resolution) {
    vec2 st = pixelCoord.xy / resolution.xy;
    st -= vec2(0.5, 0.5);
    st *= 2.0;
    st.y *= resolution.y / resolution.x;
    return st;
}

vec4 blend(vec4 src, vec4 dst) {
    return vec4(mix(dst.rgb, src.rgb, src.a), src.a + dst.a * (1.0 - src.a));
}

// Function by Iñigo Quilez (https://www.iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm)
float sdTriangle(in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2) {
    vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
    vec2 v0 = p - p0, v1 = p - p1, v2 = p - p2;
    vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0);
    vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0);
    vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0);
    float s = sign(e0.x * e2.y - e0.y * e2.x);
    vec2 d = min(min(vec2(dot(pq0, pq0), s * (v0.x * e0.y - v0.y * e0.x)),
    vec2(dot(pq1, pq1), s * (v1.x * e1.y - v1.y * e1.x))),
    vec2(dot(pq2, pq2), s * (v2.x * e2.y - v2.y * e2.x)));
    return - sqrt(d.x) * sign(d.y);
}

// Function by Iñigo Quilez (https://www.iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm)
float sdRoundedTriangle(in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2, in float r) {
    return sdTriangle(p, p0, p1, p2) - r;
}
#if defined(BUFFER_0)

void main() {
    vec2 st = normalizedCoordinates(gl_FragCoord.xy, u_resolution) * 1.262;
    st.x += sin(u_time * 1.0) * 0.2;

    vec2 q = vec2(0.0);
    q.x = fbm(st * vec2(0.01, 0.1) + 0.02 * u_time);
    q.y = fbm(st * vec2(0.041, 0.041) + vec2(0.780, 0.870) + 0.07 * u_time);

    vec2 r = vec2(0.0);
    r.x = fbm(st * vec2(1.2, 2.0) + 10.0 * q + vec2(-60.100, - 20.334) + 0.05 * u_time);
    r.y = fbm(st * vec2(1.1, 2.0) + 0.0052 * q + vec2(-1.000, - 0.580) + 0.082 * u_time);

    float f = fbm(st * vec2(1.0, 1.8) + 0.6 * r + u_time * 0.04);
    gl_FragColor = vec4((f * f * f + 0.024 * f * f + 0.684 * f), r.x * r.x, q.x * r.y, 1.0);
}

#else

void main() {
    vec2 st = normalizedCoordinates(gl_FragCoord.xy, u_resolution);
    vec4 noise = texture2D(u_buffer0, gl_FragCoord.xy / u_resolution.xy);
    vec4 color = COLOR_4;

    float layer1 = smoothstep(0.499, 0.5, noise.r);
    float layer2 = smoothstep(0.249, 0.25, noise.g);
    float layer3 = smoothstep(0.179, 0.18, noise.b);
    color = blend(vec4((COLOR_1).rgb, layer3), color);
    color = blend(vec4((COLOR_2).rgb, layer2), color);
    color = blend(vec4((COLOR_3).rgb, layer1), color);
    float dithering = random(st * 1.0 + u_time * vec2(0.01, 0.0));
    color.rgb *= 0.95 + dithering * 0.05;
    vec2 stT = st;
    // stT *= rotate2d(PI/2.);
    float t = 1.-step(0.012, sdRoundedTriangle(stT * 1.7, vec2(-0.8,-1.7), vec2(-0.8, -1.3), vec2(-0.3, -1.35), 0.4));
    color = blend(vec4((COLOR_6).rgb, t), color);
    gl_FragColor = color;
}

#endif