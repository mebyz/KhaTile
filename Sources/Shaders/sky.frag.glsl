#version 320 es
precision mediump float; 
 
layout(location = 0) out vec4 outColor;  // you can pick any name

// Interpolated values from the vertex shaders
in vec2 vUV;

// Values that stay constant for the whole mesh.
uniform sampler2D sky;
 
void main() {
  outColor = vec4(1.0,1.0,1.0,1.0);
}