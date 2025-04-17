#version 460 core
#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

uniform vec2 resolution;
uniform float iTime;

void main(){
    float strength = 0.25;
    float t = iTime / 8.0;
    vec3 col = vec3(0);
    vec2 pos = FlutterFragCoord().xy / resolution.xy;
    pos = 4.0 * (vec2(0.5) - pos);

    for (float k = 1.0; k < 7.0; k += 1.0) {
        pos.x += strength * sin(2.0 * t + k * 1.5 * pos.y) + t * 0.5;
        pos.y += strength * cos(2.0 * t + k * 1.5 * pos.x);
    }

    // Color palette adjustments for blue, pink, purple, and cyan shades
    col += 0.5 + 0.5 * cos(iTime + pos.xyx + vec3(1.5, 3.0, 4.5)); // Adjust phases for different hues
    col = mix(col, vec3(0.2, 0.1, 0.6), 0.5); // Shift toward bluish tones
    col = pow(col, vec3(0.4545)); // Gamma correction

    fragColor = vec4(col, 1.0);
}
