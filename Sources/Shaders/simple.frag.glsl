#version 330
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
/*  outColor = vec4(1.0,1.0,1.0,1.0);
  vec4 sd = texture( sand, vUV, 1.0);
  vec4 s = texture( grass, vUV, 1.0 );
  vec4 g = texture( stone, vUV, 1.0);

  vec4 sn = texture( snow, vUV, 1.0);*/

  vec4 sd = (smoothstep(-400.0, -300.0, vHeight) - smoothstep(-250.0, -20.0, vHeight)) * texture( sand, vUV*5.0 );
  vec4 s = (smoothstep(-230.0, 0.0, vHeight) - smoothstep(-100.0, 100.0, vHeight)) * texture( grass, vUV );
  vec4 g = (smoothstep(-100.0, 100.0, vHeight) - smoothstep(200.0, 250.0, vHeight)) * texture( stone, vUV *5.0);
  vec4 sn = (smoothstep(200.0, 250.0, vHeight) - smoothstep(800.0, 1000.0, vHeight)) * texture( snow, vUV *5.0);
  outColor = g+s+sd+sn;
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
  