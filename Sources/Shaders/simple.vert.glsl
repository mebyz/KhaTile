#version 320 es
precision highp float;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 uv;
layout(location = 2) in vec3 vertexNormal;

out vec2 vUV;
out float vHeight;
out vec3 vNorm;
out vec3 FragPos;

uniform mat4 MVP;

void main() {
  vNorm = vertexNormal;
  gl_Position = MVP * vec4(pos, 1.0);
  vHeight = pos.y;
  vUV = uv;
  FragPos = pos;
}