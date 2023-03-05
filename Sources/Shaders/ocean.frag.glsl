#version 450
precision highp float;

in vec2 v_textureCoordinates;
out vec4 outColor;
uniform sampler2D render_texture;
uniform sampler2D s_texture;
uniform sampler2D s_normals;
in vec4 clipSpace;
in float v_time;

//in vec3 fromFragmentToCamera;
uniform vec3 light_position;
uniform vec3 eye_position;

const vec3 DiffuseLight = vec3(0.15, 0.05, 0.0);
const vec3 RimColor = vec3(0.2, 0.2, 0.2);

in vec3 world_pos;
in vec3 world_normal;
//in vec4 viewSpace;

const vec3 fogColor = vec3(0.5, 0.5,0.5);
const float FogDensity = 0.0001;

uniform sampler2D gColor;


void main() {
    
    vec2 ndc = (clipSpace.xy / clipSpace.w);
  
    // Reflections are upside down
    vec2 reflectTexCoords = vec2(ndc.x, -ndc.y)/ 2.0 + 0.5;
    
    const float pi = 3.14285714286;
    vec3 rtex = texture(render_texture, reflectTexCoords).rgb;

    vec3 tex1 = texture(s_texture, v_textureCoordinates).rgb;

    vec3 normal = texture(s_normals, v_textureCoordinates).rgb * sin( pi * v_time/10.0);
    normal = normalize(normal * 2.0 - 1.0);   
    vec3 L = normalize( light_position - world_pos);
    vec3 V = normalize( eye_position - world_pos);

    vec3 diffuse = DiffuseLight * max(0.0, dot(L,world_normal));

    float rim = 1.0 - max(dot(V, world_normal), 0.0);
    rim = smoothstep(0.6, 1.0, rim);
    vec3 finalRim = RimColor * vec3(rim, rim, rim);
 
    vec3 lightColor = finalRim + diffuse + tex1;

    vec3 finalColor = vec3(0.0, 0.0, 0.0);

    float dist = 0.0;
    float fogFactor = 0.0;

    dist = (gl_FragCoord.z / gl_FragCoord.w);
    
   fogFactor = 1.0 /exp( (dist * FogDensity)* (dist * FogDensity));
   fogFactor = clamp( fogFactor, 0.0, 1.0 );

   finalColor = mix(fogColor, lightColor, fogFactor)*2.0;

  outColor = vec4(mix(mix(mix(tex1,finalColor,0.5),rtex,0.2),normal,0.005), 1.0);

}