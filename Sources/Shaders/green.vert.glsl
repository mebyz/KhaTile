#version 320 es

precision highp float;

// Input vertex data, different for all executions of this shader
in vec3 pos;

// Output data - will be interpolated for each fragment.
//out vec3 fragmentColor;

// Values that stay constant for the whole mesh
uniform mat4 MVP;
layout(location = 1) in vec2 uv;
out vec2 vUV;
void main() {
  // Output position of the vertex, in clip space: MVP * position
  gl_Position = MVP * vec4(pos, 1.0);
  vUV = uv;

}