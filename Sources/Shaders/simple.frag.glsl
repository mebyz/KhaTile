#version 420
precision mediump float; 
 
layout(location = 0) out vec4 outColor;  // you can pick any name

// Interpolated values from the vertex shaders
in vec2 vUV;
in float vHeight;

// Values that stay constant for the whole mesh.
uniform sampler2D sand;
uniform sampler2D stone;
uniform sampler2D grass;
uniform sampler2D snow;
 
void main() {
  vec4 sd = (smoothstep(-400.0, -300.0, vHeight) - smoothstep(-250.0, -20.0, vHeight)) * textureLod( sand, vUV, 0.2);
  vec4 s = (smoothstep(-230.0, 0.0, vHeight) - smoothstep(-100.0, 100.0, vHeight)) * textureLod( grass, vUV, 0.2 );
  vec4 g = (smoothstep(-100.0, 100.0, vHeight) - smoothstep(200.0, 250.0, vHeight)) * textureLod( stone, vUV, 0.2 );
  vec4 sn = (smoothstep(200.0, 250.0, vHeight) - smoothstep(800.0, 1000.0, vHeight)) * textureLod( snow, vUV, 0.2 );
  outColor = g+s+sd+sn;
}