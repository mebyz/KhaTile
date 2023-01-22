#version 320 es
precision highp float;

uniform mat4 MVP;
uniform sampler2D s_texture;

in vec2 uv;
in vec3 in_normal;
in vec4 a_position;

uniform float time;
uniform mat4 model_matrix, view_matrix, projection_matrix;

out vec2 v_textureCoordinates;
out vec3 world_pos;
out vec3 world_normal;
out vec4 viewSpace;

const float pi = 3.14285714286;

void main() {
    vec4 vertexCoord = a_position;
    float distance = length(vertexCoord);
    vertexCoord.y += sin(3.0 * pi * distance * 0.3 + time) * 2.0;
    v_textureCoordinates = uv;
    
    //used for lighting models
    world_pos = (model_matrix * vertexCoord).xyz;
    world_normal = normalize(mat3(model_matrix) * in_normal);

    //send it to fragment shader
    viewSpace = view_matrix * model_matrix * vertexCoord;

    gl_Position = MVP * vertexCoord;
}