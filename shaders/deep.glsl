// Author: mcxsic
// Title: Geometric (codevember 2019)

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

#define COLOR_1 vec4(20.0 , 26.0, 24.0, 255.0) / 255.0
#define COLOR_2 vec4(241.0, 240.0, 239.0, 255.0) / 255.0
#define COLOR_3 vec4(216.0, 2.0, 43.0, 255.0) / 255.0
#define CENTER vec2(0.0, 0.0)
#define CENTER_COMP vec2(0.0, 1.7)
#define SMOOTH 0.002

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float stroke(float x, float s, float w) {
    float d = smoothstep(s - SMOOTH, s + SMOOTH, x + w * 0.5) - smoothstep(s - SMOOTH, s + SMOOTH, x - w * 0.5);
    return clamp(d, 0.0, 1.0);
}

float fill(float x, float s) {
    return 1. - smoothstep(s - SMOOTH, s + SMOOTH, x);
}

float gradient(float x, float stop1, float stop2) {
    return smoothstep(stop1, stop2, x);
}

// The Book Of Shaders implementation (https://thebookofshaders.com/11/)
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 normalizedCoordinates(vec2 pixelCoord, vec2 resolution) {
    vec2 st = pixelCoord.xy / resolution.xy;
    st -= vec2(0.5, 0.5);
    st *= 2.0;
    st.y *= resolution.y / resolution.x;
    return st;
}

float triSDF(vec2 st) {
    st = st * 2.0;
    return max(abs(st.x) * 0.866025 + st.y * 0.5,abs(st.x) * 0.866025 - st.y * 0.5);
}

float triangle(vec2 st, float size) {
    return fill(triSDF(st), size);
}

vec4 color(float mask, vec4 color) {
    float srcAlpha = mask * color.a;
    return vec4(mix(vec3(0.), color.rgb, srcAlpha), srcAlpha);
}

vec4 blend(vec4 src, vec4 dst) {
    return vec4(mix(dst.rgb, src.rgb, src.a), src.a + dst.a * (1.0 - src.a));
}

vec4 generateScene(vec2 st, vec2 center, float time) {
    vec4 color = vec4((COLOR_3).rgb, 0.0);
    return color;
}

void main() {
    vec2 st = normalizedCoordinates(gl_FragCoord.xy, u_resolution);
    vec2 stC = (st - CENTER_COMP);
    vec4 bgd = COLOR_1;

    float mask = stroke(stC.y, 0.0, 0.03);
    vec4 shape = color(triangle(stC, 1.2), COLOR_3);


    vec4 color = blend(shape, bgd);
    gl_FragColor.rgb = mix(color.rgb, (COLOR_2).rgb, color.a * mask), color.a * mask;
    gl_FragColor.a = 1.;
}