// Author: mcxsic
// Title: Geometric (codevember 2019)

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

#define COLOR_1 vec4(20.0 , 26.0, 24.0, 255.0) / 255.0
#define COLOR_2 vec4(241.0, 240.0, 239.0, 255.0) / 255.0
#define COLOR_3 vec4(216.0, 2.0, 43.0, 255.0) / 255.0
#define COLOR_4 vec4(63.0, 10.0, 16.0, 255.0) / 255.0
#define COLOR_5 vec4(214.0, 213.0, 212.0, 255.0) / 255.0
#define CENTER vec2(0.0, 0.0)
#define CENTER_COMP vec2(0.0, 1.4)
#define SMOOTH 0.002

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float stroke(float x, float s, float w) {
    float d = smoothstep(s - SMOOTH, s + SMOOTH, x + w * 0.5) - smoothstep(s - SMOOTH, s + SMOOTH, x - w * 0.5);
    return clamp(d, 0.0, 1.0);
}

float strokeScl(float x, float s, float w) {
    return stroke(x, s, s * w);
}

float fill(float x, float s) {
    return 1.0 - smoothstep(s - SMOOTH, s + SMOOTH, x);
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

float wave(vec2 st, float size, float width) {
    return (1.0 - step(size * width, abs(st.x))) * strokeScl(-st.y, size * (1.0 + 0.1 * sin(PI * st.x * 2.0 / size)), 0.2);
    // return stroke(sin(PI * st.x) * step(width, abs(st.x)), size, 0.1);
}

float triSDF(vec2 st) {
    st = st * 2.0;
    return max(abs(st.x) * 0.866025 + st.y * 0.5, abs(st.x) * 0.866025 - st.y * 0.5);
}

float circleSDF(vec2 st) {
    return length(st);
}

float triangle(vec2 st, float size) {
    float tr = triSDF(st);
    return fill(tr, size) - fill(tr, size * 0.5);
}

float cresentfMoon(vec2 st, float size) {
    float shape = fill(circleSDF(vec2(st.x, st.y + size * 0.65)), size * 0.35);
    shape *= 1.0 - fill(circleSDF(vec2(st.x, st.y + size * 0.8)), size * 0.25);
    return shape;
}

vec2 triangleWithShape(vec2 st, float size, float shape) {
    float tr = triSDF(st);
    float pos = fill(tr, size);
    float neg = fill(tr, size * 0.5);
    return vec2(pos - neg, shape * (1.0 - neg));
}

vec2 triangleWithMoon(vec2 st, float size) {
    return triangleWithShape(st, size, cresentfMoon(st, size));
}

vec2 triangleWithWave(vec2 st, float size) {
    return triangleWithShape(st, size, wave(st, size * 0.4, 1.7));
}

vec4 color(float mask, vec4 color) {
    float srcAlpha = mask * color.a;
    return vec4(color.rgb, srcAlpha);
}

vec4 blend(vec4 src, vec4 dst) {
    return vec4(mix(dst.rgb, src.rgb, src.a), src.a + dst.a * (1.0 - src.a));
}

vec4 generateScene(vec2 st, float time) {
    float rand = random(st);
    float randT = random(st + vec2(time * 0.01, 0.0));
    vec4 bgd = COLOR_1;
    vec2 s;
    float hLine = stroke(st.y, 0.0, 0.01);
    float t = fract(time / 15.0);
    vec4 shape = color(triangle(st, 20.0 * t * t * t * t), COLOR_3);
    t = fract((time + 3.75) / 15.0);
    s = triangleWithWave(st, 20.0 * t * t * t * t);
    vec4 shape2 = blend(color(s.y, COLOR_3), color(s.x, COLOR_2));

    t = fract(max(time + 7.5, 0.0) / 15.0);
    vec4 shape3 = color(triangle(st, 20.0 * t * t * t * t), COLOR_3);

    t = fract(max(time + 11.25, 0.0) / 15.0);
    s = triangleWithMoon(st, 20.0 * t * t * t * t);
    vec4 shape4 = blend(color(s.y, COLOR_3), color(s.x, COLOR_5));

    vec4 color = blend(shape, bgd);
    color = blend(shape2, color);
    color = blend(shape3, color);
    color = blend(shape4, color);

    color.rgb = mix((COLOR_1).rgb + 0.02 * randT, color.rgb, 1.0 - gradient(st.y, - 0.9, 0.0) + 1.0 * gradient(st.y, 0.0, 0.9));
    // color.rgb = mix((COLOR_1).rgb, color.rgb, 1. - step(0., st.y) + 0.4 * step(0., st.y));
    color.rgb = mix(color.rgb, (COLOR_1).rgb + 0.005, color.a * hLine), color.a * hLine;
    // color = blend(vec4((COLOR_2).rgb, 0.005*(1.-gradient(abs(st.y), 0.0, 0.1))), color);

    return color;
}

void main() {
    vec2 st = normalizedCoordinates(gl_FragCoord.xy, u_resolution);
    vec2 stC = (st - CENTER_COMP);
    vec4 c = generateScene(stC, u_time);
    // vec4 wave = color(wave(stC, 0.3, 0.8), COLOR_5);
    // gl_FragColor = wave;
    gl_FragColor = c;
}