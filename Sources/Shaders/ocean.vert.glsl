#version 450
precision highp float;

uniform mat4 MVP;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 uv;

//uniform sampler2D s_texture;
//in vec2 a_texcoord;
//uniform vec3 camPos;
//in vec2 uv;
//in vec4 a_position;

//uniform float time;
//uniform mat4 model_matrix, view_matrix, projection_matrix;

out vec2 v_textureCoordinates;
//out vec3 world_pos;
//out vec3 world_normal;
//out vec4 viewSpace;
//out float v_time;

out vec4 clipSpace;

//out vec3 fromFragmentToCamera;
//out vec2 textureCoords;

//const float pi = 3.14285714286;

void main() {
    //v_textureCoordinates = a_texcoord;
    //v_time = time;
    //vec4 vertexCoord = a_position;
    
    //float distance = length(a_position);
    //a_position.y += sin( pi * distance + time);
    //v_textureCoordinates = uv;


    //viewSpace = view_matrix * model_matrix * a_position;

    //vec4 worldPosition = model_matrix * a_position;
    clipSpace = MVP * vec4(pos.x,pos.y,pos.z ,1.0);

    gl_Position = clipSpace;
    
    //textureCoords = a_position + 0.5;

    //fromFragmentToCamera = camPos - worldPosition.xyz;
}