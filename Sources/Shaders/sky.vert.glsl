#version 330
precision highp float;

// Input vertex data, different for all executions of this shader
layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 uv;
// Output data: will be interpolated for each fragment.
out vec2 vUV;
out float vHeight;
out vec3 v_normal;
// Values that stay constant for the whole mesh
uniform mat4 MVP, modelMatrix;

void main() {
  // Output position of the vertex, in clip space: MVP * position
  gl_Position = MVP * vec4(pos, 1.0);
  vHeight = pos.y;
  vUV = uv;
  v_normal = normalize(pos.xyz);
}