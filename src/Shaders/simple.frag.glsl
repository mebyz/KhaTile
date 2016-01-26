
#ifdef GL_ES
precision mediump float;
#endif

// Interpolated values from the vertex shaders
varying vec2 vUV;
varying float vHeight;

// Values that stay constant for the whole mesh.
uniform sampler2D stone;
uniform sampler2D grass;

void kore() {

  // Output color = color of the texture at the specified UV
  gl_FragColor = texture2D(grass, vUV)*vHeight/100.0+texture2D(stone, vUV)*(1.0-vHeight/50.0);
}
    