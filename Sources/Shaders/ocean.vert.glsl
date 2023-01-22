#version 320 es
precision highp float;

uniform mat4 MVP;
uniform sampler2D s_texture;

in vec4 a_position;
/*layout(location = 1) in vec3 in_position;
layout(location = 2) in vec3 in_normal;*/
out vec2 v_textureCoordinates;
layout(location = 1) in vec2 uv;
layout(location = 2) in vec3 in_normal;

uniform mat4 model_matrix, view_matrix, projection_matrix;

out vec3 world_pos;
out vec3 world_normal;
uniform float time;

const float pi = 3.14285714286;

out vec4 viewSpace;

void main() {
    vec4 vertexCoord = a_position;
    /*float distance = length(vertexCoord);
    //vertexCoord.y = 1.0;
    vertexCoord.y += sin(3.0 * pi * distance * 0.3 + time) * 2.0;*/
    v_textureCoordinates = uv;
    
    //used for lighting models
    world_pos = (model_matrix * vertexCoord).xyz;
    world_normal = normalize(mat3(model_matrix) * in_normal);

    //send it to fragment shader
    viewSpace = view_matrix * model_matrix * vertexCoord;
    //gl_Position = projection_matrix * viewSpace;
    //gl_Position = MVP * vertexCoord;
    

    gl_Position = MVP * vertexCoord;
}