#version 320 es
precision highp float;

// Input vertex data, different for all executions of this shader
layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 uv;

//layout (location = 2) in vec3 aNormal;
//out vec3 Normal;
// Output data: will be interpolated for each fragment.
out vec2 vUV;
out float vHeight;
out vec3 vNorm;
//out vec3 FragPos;

// Values that stay constant for the whole mesh
uniform mat4 MVP;
uniform vec3 vertexNormal;

void main() {
  vNorm = vertexNormal * 10.0;
  // Output position of the vertex, in clip space: MVP * position
  gl_Position = MVP * vec4(pos, 1.0);
  vHeight = pos.y;
  // UV of the vertex. No special space for this one.
  vUV = uv;
  //Normal = aNormal;
  //FragPos = pos;
}