#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;

// Interpolated values from the vertex shaders
varying vec3 fragmentColor;
varying vec2 vUV;

void kore() {
	// Output color = color specified in the vertex shader,
	// interpolated between all 3 surrounding vertices
	//gl_FragColor = vec4(fragmentColor, 1.0);

	gl_FragColor = texture2D( texture, vUV );
//	gl_FragColor = vec4(0.0, 0.5, 0.5, 1.0);
}