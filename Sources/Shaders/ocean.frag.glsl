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

uniform sampler2D normalTexture;
uniform sampler2D maskTexture;


  uniform mat4 lensProjection;


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


  float maxDistance = 8000.0;
  float resolution  = 0.3;
  int   steps       = 5;
  float thickness   = 0.5;
  ivec2 texSize = textureSize(s_texture, 0);
  vec2 texCoord = gl_FragCoord.xy / vec2(texSize.x,texSize.y);

  vec4 uv = vec4(1.0);

  vec4 positionFrom = texture(s_texture, texCoord);
  vec4 mask         = texture(maskTexture,     texCoord);
  vec3 unitPositionFrom = normalize(positionFrom.xyz);
  vec3 normal           = normalize(texture(normalTexture, texCoord).xyz);
  vec3 pivot            = normalize(reflect(unitPositionFrom, normal));

  vec4 positionTo = positionFrom;

  vec4 startView = vec4(positionFrom.xyz + (pivot *         0.0), 1.0);
  vec4 endView   = vec4(positionFrom.xyz + (pivot * maxDistance), 1.0);

  vec4 startFrag      = startView;
       startFrag      = lensProjection * startFrag;
       startFrag.xyz /= startFrag.w;
       startFrag.xy   = startFrag.xy * 0.5 + 0.5;
       startFrag.xy  *= vec2(texSize.x,texSize.y);

  vec4 endFrag      = endView;
       endFrag      = lensProjection * endFrag;
       endFrag.xyz /= endFrag.w;
       endFrag.xy   = endFrag.xy * 0.5 + 0.5;
       endFrag.xy  *= vec2(texSize.x,texSize.y);

  vec2 frag  = startFrag.xy;
       uv.xy = frag / vec2(texSize.x,texSize.y);

  float deltaX    = endFrag.x - startFrag.x;
  float deltaY    = endFrag.y - startFrag.y;
  float useX      = abs(deltaX) >= abs(deltaY) ? 1.0 : 0.0;
  float delta     = mix(abs(deltaY), abs(deltaX), useX) * clamp(resolution, 0.0, 1.0);
  vec2  increment = vec2(deltaX, deltaY) / max(delta, 0.001);

  float search0 = 0.0;
  float search1 = 0.0;

  int hit0 = 0;
  int hit1 = 0;

  float viewDistance = startView.y;
  float depth        = thickness;

  int i = 0;

  for (i = 0; i < int(delta); ++i) {
    frag      += increment;
    uv.xy      = frag / vec2(texSize.x,texSize.y);
    positionTo = texture(s_texture, uv.xy);

    search1 =
      mix
        ( (frag.y - startFrag.y) / deltaY
        , (frag.x - startFrag.x) / deltaX
        , useX
        );

    search1 = clamp(search1, 0.0, 1.0);

    viewDistance = (startView.y * endView.y) / mix(endView.y, startView.y, search1);
    depth        = viewDistance - positionTo.y;

    if (depth > 0.0 && depth < thickness) {
      hit0 = 1;
      break;
    } else {
      search0 = search1;
    }
  }

  search1 = search0 + ((search1 - search0) / 2.0);

  steps *= hit0;

  for (i = 0; i < steps; ++i) {
    frag       = mix(startFrag.xy, endFrag.xy, search1);
    uv.xy      = frag / vec2(texSize.x,texSize.y);
    positionTo = texture(s_texture, uv.xy);

    viewDistance = (startView.y * endView.y) / mix(endView.y, startView.y, search1);
    depth        = viewDistance - positionTo.y;

    if (depth > 0.0 && depth < thickness) {
      hit1 = 1;
      search1 = search0 + ((search1 - search0) / 2.0);
    } else {
      float temp = search1;
      search1 = search1 + ((search1 - search0) / 2.0);
      search0 = temp;
    }
  }

  float visibility =
      float(hit1)
    * positionTo.w
    * ( 1.0
      - max
         ( dot(-unitPositionFrom, pivot)
         , 0.0
         )
      )
    * ( 1.0
      - clamp
          ( depth / thickness
          , 0.0
          , 1.0
          )
      )
    * ( 1.0
      - clamp
          (   length(positionTo - positionFrom)
            / maxDistance
          , 0.0
          , 1.0
          )
      )
    * (uv.x < 0.0 || uv.x > 1.0 ? 0.0 : 1.0)
    * (uv.y < 0.0 || uv.y > 1.0 ? 0.0 : 1.0);

  visibility = clamp(visibility, 0.0, 1.0);

  uv.ba = vec2(visibility);








   outColor = mix(uv, vec4(finalColor, 1.0), 1.0);

}