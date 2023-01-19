#version 330
precision highp float;
 
layout(location = 1) out vec4 outColor;  // you can pick any name
// Interpolated values from the vertex shaders
in vec2 vUV;
in float vHeight;

// Values that stay constant for the whole mesh.
uniform sampler2D sand;
uniform sampler2D stone;
uniform sampler2D grass;
uniform sampler2D snow;
 
void main() {
   outColor = vec4(1.0,1.0,1.0,1.0);
}
/*#version 320 es
#ifdef GL_ES
precision mediump float;
#endif


void main() {
*/
  // Output color = color of the texture at the specified UV
/*  vec4 sd = (smoothstep(-400.0, -300.0, vHeight) - smoothstep(-250.0, -20.0, vHeight));// * texture2D( sand, vUV);
  vec4 s = (smoothstep(-230.0, 0.0, vHeight) - smoothstep(-100.0, 100.0, vHeight));// * texture2D( grass, vUV );
  vec4 g = (smoothstep(-100.0, 100.0, vHeight) - smoothstep(200.0, 250.0, vHeight));// * texture2D( stone, vUV);

  vec4 sn = (smoothstep(200.0, 250.0, vHeight) - smoothstep(800.0, 1000.0, vHeight));// * texture2D( snow, vUV);*/
  // =vec4(1.0,1.0,1.0,1.0); // g+s+sd+sn;
//}
  