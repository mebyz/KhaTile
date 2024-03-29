#version 450
precision mediump float;

// Interpolated values from the vertex shaders
out vec4 color;

void main() {
	// Output color = color specified in the vertex shader,
	// interpolated between all 3 surrounding vertices
	//gl_FragColor = vec4(fragmentColor, 1.0);

	color = vec4(1.0, 0.0, 0.0, 1.0);
}