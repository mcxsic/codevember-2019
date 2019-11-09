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
#define SMOOTH 0.005

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_buffer0;

mat2 rotate2d(in float angle) {
    return mat2(cos(angle), - sin(angle), sin(angle), cos(angle));
}

float fill(float x, float s) {
    return 1.0 - smoothstep(s - SMOOTH, s + SMOOTH, x);
}

float stroke(float x, float s, float w) {
    float d = smoothstep(s - SMOOTH, s + SMOOTH, x + w * 0.5) - smoothstep(s - SMOOTH, s + SMOOTH, x - w * 0.5);
    return clamp(d, 0.0, 1.0);
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

float hornSDF(vec2 st) {
    st = st * 2.0;
    return max(abs(st.x) * 1.866025 + st.y * 0.5, abs(st.x) * 0.866025 - st.y * 0.5);
}

float triSDF(vec2 st) {
    st = st * 2.0;
    return max(abs(st.x) * 0.966025 + st.y * 0.5, abs(st.x) * 0.966025 - st.y * 0.5);
}

float triangle(vec2 st, float size) {
    return fill(triSDF(st), size);
}

float horn(vec2 st, float size) {
    return fill(hornSDF(st), size);
}

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

    vec2 stT = st;
    float dithering = random(st * 1.0 + u_time * vec2(0.01, 0.0));
    stT += vec2(0.65, -1.4);
    stT *= rotate2d(-PI / 7.0);

    float t = horn(stT, 0.5) + triangle(stT + vec2(0.0, 0.9), 0.3);
    stT = st;

    stT *= rotate2d(PI / 2.7);
    t += 0.4 * stroke(stT.x, 1.15, 0.05);

    stT = st;
    stT *= rotate2d(PI / 1.6);
    t = min(t + 0.4 * stroke(stT.x, 0.9, 0.05), 1.0);

    color = blend(vec4((COLOR_6).rgb, (0.95 + dithering * 0.05) * t * 0.89), color);

    color.rgb *= 0.95 + dithering * 0.05;
    gl_FragColor = color;
}

#endif