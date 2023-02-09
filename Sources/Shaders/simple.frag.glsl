#version 450
precision mediump float; 
 
layout(location = 0) out vec4 outColor;  

in vec2 vUV;
in float vHeight;
in vec3 vNorm;
in vec3 FragPos;

uniform sampler2D sand;
uniform sampler2D stone;
uniform sampler2D grass;
uniform sampler2D snow;
 
void main() {
  vec3 lightColor = vec3(0.5,0.5,0.5);
  float ambientStrength = 0.2;
  vec3 ambient = ambientStrength * lightColor;
  vec3 lightPos = vec3(100.0,100.0,100.0);
  vec3 norm = normalize(vNorm);
  vec3 lightDir = normalize(lightPos - FragPos); 
  float diff = max(dot(norm, lightDir),0.01);
  vec3 diffuse = diff * lightColor; 
  vec4 sd =  (smoothstep(-1200.0, 100.0, vHeight) - smoothstep(100.0*norm.x, 250.0, vHeight)) * texture( sand, vUV, 1.2 ) * (norm.x/2.0+0.5);
  vec4 s =(smoothstep(-1200.0, 100.0*norm.x, vHeight) - smoothstep(100.0*norm.x, 250.0, vHeight)) * texture( grass, vUV, 2.0 ) * (1.0-norm.x-0.2) / 2.0;
  vec4 g = (smoothstep(200.0*norm.x, 450.0, vHeight) - smoothstep(450.0*norm.x, 3000.0, vHeight)) * texture( stone, vUV, 1.2 ) * (1.0-norm.z-0.5);
  vec4 sn = (smoothstep(200.0*norm.x, 450.0, vHeight) - smoothstep(450.0*norm.x, 3000.0, vHeight)) * texture( snow, vUV, 1.2 ) * (norm.z+0.5);
  outColor = (vec4(ambient, 1.0)+vec4(diffuse, 1.0)+vec4(vNorm, 1.0) )/10.0 + (g+s+sd+sn);
}