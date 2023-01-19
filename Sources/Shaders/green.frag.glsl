#version 330
#ifdef GL_ES
precision mediump float;
#endif

// Interpolated values from the vertex shaders
//out vec3 fragmentColor;

void main() {
	// Output color = color specified in the vertex shader,
	// interpolated between all 3 surrounding vertices
	//gl_FragColor = vec4(fragmentColor, 1.0);

	gl_FragColor = vec4(0.0, 0.5, 0.9, 1.0);
}