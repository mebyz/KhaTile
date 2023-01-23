#version 320 es
precision highp float;

// Input vertex data, different for all executions of this shader
layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 uv;
// Output data: will be interpolated for each fragment.
out vec2 vUV;
out float vHeight;

// Values that stay constant for the whole mesh
uniform mat4 MVP, modelMatrix, projectionMatrix;

void main() {
  // Output position of the vertex, in clip space: MVP * position
  gl_Position = MVP * vec4(pos, 1.0);
  vHeight = pos.y;
  vUV = uv;
}