#version 320 es
precision mediump float; 
 
layout(location = 0) out vec4 outColor;  // you can pick any name

// Interpolated values from the vertex shaders
in vec2 vUV;
in float vHeight;
//in vec3 Normal;
//in vec3 FragPos;

// Values that stay constant for the whole mesh.
uniform sampler2D sand;
uniform sampler2D stone;
uniform sampler2D grass;
uniform sampler2D snow;
 
void main() {
  /*vec3 lightColor = vec3(0.5,0.5,0.5);
  float ambientStrength = 0.9;
  vec3 ambient = ambientStrength * lightColor;
  vec3 lightPos = vec3(100.0,100.0,100.0);
  vec3 norm = normalize(Normal);
  vec3 lightDir = normalize(lightPos - FragPos); 
  float diff = max(dot(norm, lightDir),0.01);
  vec3 diffuse = diff * lightColor; */
  vec4 sd = (smoothstep(-1800.0, -300.0, vHeight) - smoothstep(-250.0, -20.0, vHeight)) * texture( sand, vUV, 1.0);
  vec4 s = (smoothstep(-230.0, 0.0, vHeight) - smoothstep(-100.0, 100.0, vHeight)) * texture( grass, vUV, 1.0 );
  vec4 g = (smoothstep(-100.0, 100.0, vHeight) - smoothstep(400.0, 550.0, vHeight)) * texture( stone, vUV, 1.0 );
  vec4 sn = (smoothstep(400.0, 550.0, vHeight) - smoothstep(800.0, 2000.0, vHeight)) * texture( snow, vUV, 1.0 );
  outColor = texture( sand, vUV, 1.0);// (vec4(ambient,1.0)+ vec4(diffuse, 1.0)) *(g+s+sd+sn);
}