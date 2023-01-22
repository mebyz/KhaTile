#version 320 es
precision lowp float;

in vec2 v_textureCoordinates;
out vec4 outColor;
uniform sampler2D s_texture;

void main() {
    outColor = texture(s_texture, v_textureCoordinates);
}