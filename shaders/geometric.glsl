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
#define SMOOTH 0.006

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// The Book Of Shaders implementation (https://thebookofshaders.com/11/)
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

/* Math 2D Transformations */
mat2 rotate2d(in float angle) {
    return mat2(cos(angle), - sin(angle), sin(angle), cos(angle));
}

vec2 normalizedCoordinates(vec2 pixelCoord, vec2 resolution) {
    vec2 st = pixelCoord.xy / resolution.xy;
    st -= vec2(0.5, 0.5);
    st *= 2.0;
    st.y *= resolution.y / resolution.x;
    return st;
}

float square(vec2 st, vec2 center, float dist) {
    float h = 1.0 - smoothstep(dist - SMOOTH, dist + SMOOTH, distance(st.x, center.x));
    float v = 1.0 - smoothstep(dist - SMOOTH, dist + SMOOTH, distance(st.y, center.y));
    return h * v;
}


vec4 drawShape(float mask, vec4 src, vec4 dst) {
    // src.a = 1.0;
    return vec4(mix(dst.rgb, src.rgb, mask * src.a), 1.0);
}

vec4 gradient(vec2 st, vec4 color1, vec4 color2, float slope, float scale, float dist) {
    return mix(color1, color2, clamp((st.x + dist) * scale * slope + (st.y + dist) * scale * (1.0 - slope), 0.0, 1.0));
}

void main() {
    vec2 st = normalizedCoordinates(gl_FragCoord.xy, u_resolution);
    vec4 color = COLOR_2;
    vec2 stR = (st - CENTER_COMP) * rotate2d(u_time + PI / 3.0);

    stR *= rotate2d(u_time * 0.001 + PI / 21.0);
    color = drawShape(square(stR, CENTER, 0.82), vec4((COLOR_1).rgb, 0.9), color);

    stR *= rotate2d(u_time * 0.01 + PI / 21.0);
    color = drawShape(square(stR, CENTER, 0.82), vec4((COLOR_2).rgb, 0.6), color);

    stR *= rotate2d(u_time * 0.22 + PI / 21.0);
    color = drawShape(square(stR, CENTER, 0.73), vec4((COLOR_3).rgb, 0.5), color);

    stR *= rotate2d(u_time * 0.2 + PI / 21.0);
    color = drawShape(square(stR, CENTER, 0.64), vec4((COLOR_2).rgb, 0.5), color);

    stR *= rotate2d(u_time * 0.2 + PI / 21.0);
    color = drawShape(square(stR, CENTER, 0.58), vec4((COLOR_4).rgb, 0.5), color);

    stR *= rotate2d(u_time * 0.01 + PI / 21.0);
    color = drawShape(square(stR, CENTER, 0.51), vec4((COLOR_1).rgb, 0.8), color);

    stR *= rotate2d(u_time * 0.1 + PI / 21.0);
    color = drawShape(square(stR, CENTER, 0.5), vec4((COLOR_3).rgb, 0.7), color);

    gl_FragColor = color;
}