#version 320 es
precision lowp float;

uniform mat4 MVP;
uniform sampler2D s_texture;

in vec4 a_position;
out vec2 v_textureCoordinates;
layout(location = 1) in vec2 uv;
uniform float time;

const float pi = 3.14285714286;

void main() {
    vec4 vertexCoord = a_position;
    float distance = length(vertexCoord);
    //vertexCoord.y = 1.0;
    vertexCoord.y += sin(3.0 * pi * distance * 0.3 + time) * 2.0;
    v_textureCoordinates = uv;
    
    gl_Position = MVP * vertexCoord;
}