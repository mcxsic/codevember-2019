// Author: mcxsic
// Title: Contrast (codevember 2019)

#ifdef GL_ES
precision mediump float;
#endif

/* Color palette */
#define BLACK vec3(0.0, 0.0, 0.0)
#define WHITE vec3(1.0, 1.0, 1.0)
#define RED vec3(1.0, 0.0, 0.0)
#define GREEN vec3(0.0, 1.0, 0.0)
#define BLUE vec3(0.0, 0.0, 1.0)
#define YELLOW vec3(1.0, 1.0, 0.0)
#define CYAN vec3(0.0, 1.0, 1.0)
#define MAGENTA vec3(1.0, 0.0, 1.0)
#define ORANGE vec3(1.0, 0.5, 0.0)
#define PURPLE vec3(1.0, 0.0, 0.5)
#define LIME vec3(0.5, 1.0, 0.0)
#define ACQUA vec3(0.0, 1.0, 0.5)
#define VIOLET vec3(0.5, 0.0, 1.0)
#define AZUR vec3(0.0, 0.5, 1.0)

#define COLOR_1 vec3(0.0, 68.0 / 255.0, 1.0)
#define COLOR_2 vec3(1.0, 223.0 / 255.0, 0.0)
#define COLOR_3 COLOR_1 * 0.9

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float pseudoRandom(float x) {
    float amplitude = 1.0;
    float frequency = 1.720;
    float y = sin(x * frequency);
    float t = 0.01 * (-u_time * 130.0);
    y += sin(x * frequency * 2.1 + t) * 4.5;
    y += sin(x * frequency * 1.72 + t*1.121) * 4.0;
    y += sin(x * frequency * 2.221 + t*0.437) * 5.0;
    y += sin(x * frequency * 3.1122 + t*4.269) * 2.5;
    return y;
}

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
    return mix(color1, color2, clamp((st.x + dist) * scale * slope + (st.y + dist) * scale * (1.0 - slope), 0., 1.));
}

void main() {
    vec2 st = normalizedCoordinates(gl_FragCoord.xy, u_resolution);
    float mask1 = circle(st, vec2(-2.3, 0.3), 2.7);
    vec3 color2 = mix(COLOR_2, COLOR_3, 0.5 * (1.0 + sin(u_time)));
    vec3 color = COLOR_1;
    color = mix(color, vec3(gradient(st - random(st) * 0.04, vec4(COLOR_1, 1.0), vec4(color2, 1.0), 0.5, 1.2, 0.1)), mask1);

    float mask2 = circle(st, vec2(2.4, - 1.4), 3.0);
    color = mix(color, vec3(gradient(st + random(st + 0.342) * 0.06, vec4(color2, 1.0), vec4(COLOR_1, 1.0), 0.3, 0.5, 2.0)), mask2);

    // color = vec3(st.x, cos(u_time), abs(sin(u_time)));
    gl_FragColor = vec4(color, 1.0);
}