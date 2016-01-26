
#ifdef GL_ES
precision mediump float;
#endif

// Interpolated values from the vertex shaders
varying vec2 vUV;
varying float vHeight;

// Values that stay constant for the whole mesh.
uniform sampler2D sand;
uniform sampler2D stone;
uniform sampler2D grass;

void kore() {

  // Output color = color of the texture at the specified UV
  vec4 sd = (smoothstep(-100.0, 0.0, vHeight) - smoothstep(15.0, 25.0, vHeight)) * texture2D( sand, vUV );
  vec4 s = (smoothstep(0.18, 32.0, vHeight) - smoothstep(30.0, 40.0, vHeight)) * texture2D( stone, vUV );
  vec4 g = (smoothstep(25.0, 50.0, vHeight) - smoothstep(95.0, 99.0, vHeight)) * texture2D( grass, vUV );
  gl_FragColor = g+s+sd;
}
    