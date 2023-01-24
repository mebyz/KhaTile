#version 450

#ifdef GL_ES
precision mediump float;
#endif

#define BUFFER_SIZE 16

// Amount of pixels used to smooth between borders
#define ANTIALIASING 0.6

in vec4 color;
flat in int instanceID;

// Packed values: (centerX, centerY, radius, unused (Krafix DirectX padding issue))
uniform vec4 circles[BUFFER_SIZE];

uniform vec4 borderColor[BUFFER_SIZE];
uniform vec4 shadowColors[BUFFER_SIZE];

// Packed values: (borderThickness, shadowWidth, shadowFalloff, unused)
uniform vec4 attributes[BUFFER_SIZE];

out vec4 fragColor;

/**
 * Calculate the distance from the given point to the given circle (SDF).
 * 0 at the border, inside = negative, outside = positive.
 */
float distanceToCircle(const vec2 center, const float radius, const vec2 point) {
	return length(point - center) - radius;
}

void main() {
	int iID = int(instanceID.x);

	vec4 shadowColor = shadowColors[iID];

	float dst = distanceToCircle(circles[iID].xy, circles[iID].z, gl_FragCoord.xy);

	// =========================================================================
	// SHADOW
	// =========================================================================
	// Don't divide by 0
	float shadowWidth = attributes[iID].y + 0.0001;

	// Invert, clamp and falloff
	float shadowAmount = pow(max(0, (1 - dst / shadowWidth)), attributes[iID].z);

	vec4 shadow = shadowColor;
	shadow.a *= shadowAmount;

	// =========================================================================
	// BORDER
	// =========================================================================
	float borderThickness = attributes[iID].x;

	// Calculate antialiasing only on the border, not on the shadow to prevent
	// sharp edges when not using shadows
	float borderOuter = smoothstep(-ANTIALIASING * 2, 0, dst);
	float borderInner = smoothstep(-ANTIALIASING, ANTIALIASING, dst + borderThickness);

	vec4 bgColor = color;
	bgColor = mix(bgColor, borderColor[iID], borderInner);
	bgColor = mix(bgColor, shadow, borderOuter);

	fragColor = bgColor;
}
