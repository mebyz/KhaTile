#version 420
precision mediump float;

// Interpolated values from the vertex shaders
out vec4 color;

void main() {
	// Output color = color specified in the vertex shader,
	// interpolated between all 3 surrounding vertices
	//gl_FragColor = vec4(fragmentColor, 1.0);

	color = vec4(0.0, 0.5, 0.9, 1.0);
}