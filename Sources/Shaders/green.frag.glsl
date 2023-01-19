#version 420
precision mediump float;

// Interpolated values from the vertex shaders
out vec4 color;

uniform sampler2D texture;
in vec2 vUV;
 
void main() {
	// Output color = color specified in the vertex shader,
	// interpolated between all 3 surrounding vertices
	//gl_FragColor = vec4(fragmentColor, 1.0);

	color = textureLod( texture, vUV, 0.2);
}