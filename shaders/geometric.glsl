// Author: mcxsic
// Title: Geometric (codevember 2019)

#ifdef GL_ES
precision mediump float;
#endif
#define PI 3.1416
#define COLOR_1 vec4(219.0 , 139.0, 101.0, 255.0) / 255.0
#define COLOR_2 vec4(240.0, 233.0, 173.0, 255.0) / 255.0
#define COLOR_3 vec4(75.0, 114.0, 166.0, 255.0) / 255.0
#define COLOR_4 vec4(61.0, 64.0, 115.0, 255.0) / 255.0
#define COLOR_5 vec4(57.0, 34.0, 64.0, 255.0) / 255.0
#define CENTER vec2(0.0, 0.0)
#define CENTER_COMP vec2(0.3333, 0.5)
#define SMOOTH 0.002

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float stroke(float x, float s, float w) {
    float d = smoothstep(s - SMOOTH, s + SMOOTH, x + w * 0.5) - smoothstep(s - SMOOTH, s + SMOOTH, x - w * 0.5);
    return clamp(d, 0.0, 1.0);
}

float fill(float x, float size) {
    return 1.0 - step(size, x);
}

float gradient(float x, float stop1, float stop2) {
    return smoothstep(stop1, stop2, x);
}

mat2 rotate2d(in float angle) {
    return mat2(cos(angle), - sin(angle), sin(angle), cos(angle));
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

float hexSDF(vec2 st) {
    st = abs(st);
    return max(st.y, st.x * 0.866025 + st.y * 0.5);
}

float hexagon(vec2 st, float size) {
    return stroke(hexSDF(st), size, 0.02);
    // return fill(hexSDF(st), size);
}
vec4 drawShape(float mask, vec4 src, vec4 dst) {
    // src.a = 1.0;
    float srcAlpha = mask * src.a;
    return vec4(mix(dst.rgb, src.rgb, srcAlpha), srcAlpha + dst.a * (1.0 - srcAlpha));
}

vec4 blend(vec4 src, vec4 dst) {
    return vec4(mix(dst.rgb, src.rgb, src.a), src.a + dst.a * (1.0 - src.a));
}

vec4 generateScene(vec2 st, vec2 center, float time) {
    vec4 color = vec4((COLOR_4).rgb, 0.0);
    vec2 stC = (st - CENTER_COMP);
    vec2 stR = stC;
    float dist = 0.15;

    for(int i = 0; i < 8; i ++ ) {
        stR = stC * rotate2d(time * random(vec2(float(i + 1) * 0.02)) + PI / 2.0);
        color = drawShape(hexagon(stR, 0.06 + float(i) * dist * 3.0), vec4((COLOR_1).rgb, 0.5), color);
    }

    for(int i = 0; i < 8; i ++ ) {
        stR = stC * rotate2d(time * float(i + 1) * 0.0432342 + PI / 2.0);
        color = drawShape(hexagon(stR, 0.06 + dist + float(i) * dist * 3.0), vec4((COLOR_2).rgb, 0.5), color);
    }

    for(int i = 0; i < 6; i ++ ) {
        stR = stC * rotate2d(time * float(i + 1) * 0.151234153 + PI / 2.0);
        color = drawShape(hexagon(stR, 0.06 + dist * 2.0 + float(i) * dist * 3.0), vec4((COLOR_5).rgb, 0.79), color);
    }

    return color;
}

void main() {
    vec2 st = normalizedCoordinates(gl_FragCoord.xy, u_resolution);
    vec2 stC = (st - CENTER_COMP);
    vec2 stR = stC * rotate2d(PI / 2.0);

    vec4 color = generateScene(st, CENTER_COMP, u_time * 0.1);
    // color.rgb += color.a * 0.1 * (2.0 * random(st) -1.0);
    vec4 bgd = mix(COLOR_4, COLOR_5, gradient(hexSDF(stR), 0.2, 2.2));

    color = blend(color, 0.01 * (2.0 * random(st) - 1.0) + bgd);
    gl_FragColor = color;
}