#version 320 es
precision highp float;

in vec2 v_textureCoordinates;
out vec4 outColor;
uniform sampler2D s_texture;

uniform float time;

uniform vec3 light_position;
uniform vec3 eye_position;

const vec3 DiffuseLight = vec3(0.15, 0.05, 0.0);
const vec3 RimColor = vec3(0.2, 0.2, 0.2);

//from vertex shader
in vec3 world_pos;
in vec3 world_normal;
in vec4 viewSpace;

const vec3 fogColor = vec3(0.5, 0.5,0.5);
const float FogDensity = 0.0001;

void main() {
    
    vec3 tex1 = texture(s_texture, v_textureCoordinates).rgb;

    //get light an view directions
    vec3 L = normalize( light_position - world_pos);
    vec3 V = normalize( eye_position - world_pos);

    //diffuse lighting
    vec3 diffuse = DiffuseLight * max(0.0, dot(L,world_normal));

    //rim lighting
    float rim = 1.0 - max(dot(V, world_normal), 0.0);
    rim = smoothstep(0.6, 1.0, rim);
    vec3 finalRim = RimColor * vec3(rim, rim, rim);
 
    //get all lights and texture
    vec3 lightColor = finalRim + diffuse + tex1;

    vec3 finalColor = vec3(0.0, 0.0, 0.0);

    float dist = 0.0;
    float fogFactor = 0.0;

    dist = (gl_FragCoord.z / gl_FragCoord.w);
    
   fogFactor = 1.0 /exp( (dist * FogDensity)* (dist * FogDensity));
   fogFactor = clamp( fogFactor, 0.0, 1.0 );

   finalColor = mix(fogColor, lightColor, fogFactor);
   outColor = vec4(finalColor, 1.0);

}