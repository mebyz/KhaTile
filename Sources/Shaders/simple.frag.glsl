
#version 330
#ifdef GL_ES
precision mediump float;
#endif

// Interpolated values from the vertex shaders
//out vec2 vUV;
//out float vHeight;

// Values that stay constant for the whole mesh.
/*uniform sampler2D sand;
uniform sampler2D stone;
uniform sampler2D grass;
uniform sampler2D snow;*/

void main() {

  // Output color = color of the texture at the specified UV
  /*vec4 sd = (smoothstep(-400.0, -300.0, vHeight) - smoothstep(-250.0, -20.0, vHeight)) * texture2D( sand, vUV*5.0, 0.0);
  vec4 s = (smoothstep(-230.0, 0.0, vHeight) - smoothstep(-100.0, 100.0, vHeight)) * texture2D( grass, vUV );
  vec4 g = (smoothstep(-100.0, 100.0, vHeight) - smoothstep(200.0, 250.0, vHeight)) * texture2D( stone, vUV *5.0);

  vec4 sn = (smoothstep(200.0, 250.0, vHeight) - smoothstep(800.0, 1000.0, vHeight)) * texture2D( snow, vUV *5.0);
  gl_FragColor = g+s+sd+sn;*/
}
    