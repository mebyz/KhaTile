#version 450

#ifdef GL_ES
precision mediump float;
#endif

#define BUFFER_SIZE 16

// Amount of pixels used to smooth between borders
#define ANTIALIASING 0.6

in vec4 color;
flat in int instanceID;

// Packed values: (left, right, top, bottom)
uniform vec4 rects[BUFFER_SIZE];

uniform vec4 borderColor[BUFFER_SIZE];
uniform vec4 shadowColors[BUFFER_SIZE];

// Packed values: (borderThickness, cornerRadius, shadowWidth, shadowFalloff)
uniform vec4 attributes[BUFFER_SIZE];

out vec4 fragColor;

/**
 * Calculate the distance from the given point to the given rect (SDF).
 * 0 at the border, inside = negative, outside = positive.
 */
float distanceToRect(const vec4 rect, const vec2 point) {
	float dx = max(rect.x - point.x, point.x - rect.y);
	float dy = max(rect.w - point.y, point.y - rect.z);

	vec2 dst = vec2(dx, dy);

	//     outside (> 0)         + inside (< 0)
	return length(max(dst, 0.0)) + min(max(dst.x, dst.y), 0.0);
}

void main() {
	int iID = int(instanceID.x);

	vec4 shadowColor = shadowColors[iID];
	float cornerRadius = attributes[iID].y;

	vec4 outerRect = rects[iID];
	float outerDst = distanceToRect(outerRect, gl_FragCoord.xy) - cornerRadius;

	// =========================================================================
	// SHADOW
	// =========================================================================
	// Don't divide by 0
	float shadowWidth = attributes[iID].z + 0.0001;

	// Invert, clamp and falloff
	float shadowAmount = pow(max(0, (1 - (outerDst) / shadowWidth)), attributes[iID].w);

	vec4 shadow = shadowColor;
	shadow.a *= shadowAmount;

	// =========================================================================
	// BORDER
	// =========================================================================
	float borderThickness = attributes[iID].x;
	float innerDst = outerDst + borderThickness;

	// Calculate antialiasing only on the border, not on the shadow to prevent
	// sharp edges when not using shadows
	float borderOuter = smoothstep(-ANTIALIASING * 2, 0, outerDst);
	float borderInner = smoothstep(-ANTIALIASING, ANTIALIASING, innerDst);

	vec4 bgColor = color;
	bgColor = mix(bgColor, borderColor[iID], borderInner);
	bgColor = mix(bgColor, shadow, borderOuter);

	fragColor = bgColor;
}
