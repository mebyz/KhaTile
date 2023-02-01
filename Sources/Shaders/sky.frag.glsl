#version 330
precision highp float;

in vec3 v_normal;

uniform samplerCube u_texture;

out vec4 outColor;

void main() {
   outColor = texture(u_texture, normalize(v_normal));
}