#version 450

in vec3 pos;
in vec4 col;

out vec4 color;
flat out int instanceID;

void main() {
	color = col;
	instanceID = int(pos.z);
	gl_Position = vec4(pos.x, pos.y, 0.0, 1.0);
}
