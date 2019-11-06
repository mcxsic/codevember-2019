// Author: mcxsic
// Title: Contrast (codevember 2019)

#ifdef GL_ES
precision mediump float;
#endif

#define COLOR_1 vec3(0.0, 68.0 / 255.0, 1.0)
#define COLOR_2 vec3(1.0, 223.0 / 255.0, 0.0)
#define COLOR_3 COLOR_1 * 0.9

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

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

float circle(vec2 st, vec2 center, float radius) {
    return 1.0 - smoothstep(radius - 0.002, radius + 0.002, distance(st, center));
}

float linearGradient(vec2 st, vec2 start, vec2 end, vec3 color1, vec3 color2) {
    return 1.0;
}

vec4 gradient(vec2 st, vec4 color1, vec4 color2, float slope, float scale, float dist) {
    return mix(color1, color2, clamp((st.x + dist) * scale * slope + (st.y + dist) * scale * (1.0 - slope), 0.0, 1.0));
}

void main() {
    vec2 st = normalizedCoordinates(gl_FragCoord.xy, u_resolution);
    float mask1 = circle(st, vec2(-2.3, 0.3), 2.7);
    vec3 color2 = mix(COLOR_2, COLOR_3, 0.5 * (1.0 + sin(u_time)));
    vec3 color = COLOR_1;
    vec4 circle1 = gradient(st - random(st) * 0.04, vec4(COLOR_1, 1.0), vec4(color2, 1.0), 0.5, 1.2, 0.1);
    color = mix(color, circle1.rgb, mask1 * circle1.a);

    float mask2 = circle(st, vec2(2.4, - 1.4), 3.0);
    vec4 circle2 = gradient(st + random(st + 0.342) * 0.06, vec4(color2, 1.0), vec4(COLOR_1, 1.0), 0.3, 0.5, 2.0);
    color = mix(color, circle2.rgb, mask2 * circle2.a);
    gl_FragColor = vec4(color, 1.0);
}