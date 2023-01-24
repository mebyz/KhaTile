package koui.graphics;

import kha.Canvas;
import kha.FastFloat;
import kha.Shaders;

import koui.theme.Style;

#if (KOUI_EFFECTS_OFF || KOUI_EFFECTS_SHADOW_OFF)
using kha.graphics2.GraphicsExtension;
#end

class KCirclePainter extends KPainter {
	public function new(g4: kha.graphics4.Graphics, canvas: Canvas) {
		super(g4, canvas, ["circles", "attributes", "borderColor", "shadowColors"], Shaders.rect_vert, Shaders.circle_frag);
	}

	#if (KOUI_EFFECTS_OFF || KOUI_EFFECTS_SHADOW_OFF)
	private static inline override function init() {}

	@:access(koui.elements.Element)
	public static inline function fillKCircle(
			cx: FastFloat, cy: FastFloat, radius: FastFloat,
			styleBorder: Dynamic, styleGradient: Dynamic, styleShadow: Dynamic) {
		g2.color = styleGradient.colorBottomRight;
		g2.fillCircle(cx, cy, radius);
	}
	#else

	@:access(koui.elements.Element)
	public function fillKCircle(cx: FastFloat, cy: FastFloat, radius: FastFloat, style: Style) {
		// Draw buffer if full
		if (bufferIndex + 1 >= KPainter.bufferSize) drawBuffer();

		var canvasW = canvas.width;
		var canvasH = canvas.height;

		var styleBorder = style.border;
		var styleColor = style.color;
		var styleShadow = style.dropShadow;
		var shadowWidth = styleShadow.radius;

		// Calculate shadow quad positions in window space
		var posLeft = (cx - radius - shadowWidth) / canvasW;
		var posRight = (cx + radius + shadowWidth) / canvasW;
		// Todo: use Image.renderTargetInvertedY
		#if (kha_opengl || kha_webgl)
		var posTop = ((cy - radius - shadowWidth)) / canvasH;
		var posBottom = ((cy + radius + shadowWidth)) / canvasH;
		#else
		// Invert y axis
		var posTop = (canvasH - (cy - radius - shadowWidth)) / canvasH;
		var posBottom = (canvasH - (cy + radius + shadowWidth)) / canvasH;
		#end

		// Map from [0, 1] range to [-1, 1]
		posLeft = posLeft * 2 - 1;
		posRight = posRight * 2 - 1;
		posTop = posTop * 2 - 1;
		posBottom = posBottom * 2 - 1;

		var colorTopLeft = styleColor.bg;
		var colorBottomRight = styleColor.bg;
		var direction = true;
		if (styleColor.useGradient) {
			colorTopLeft = styleColor.gradient.colorTopLeft;
			colorBottomRight = styleColor.gradient.colorBottomRight;
			direction = styleColor.gradient.direction;
		}
		setRectVertices(posLeft, posRight, posTop, posBottom);
		setRectColors(direction, colorTopLeft, colorBottomRight, style.opacity);

		uniformValues["circles"][bufferIndex * 4 + 0] = cx;
		uniformValues["circles"][bufferIndex * 4 + 1] = cy;
		uniformValues["circles"][bufferIndex * 4 + 2] = radius;
		uniformValues["circles"][bufferIndex * 4 + 3] = 0; // Unused

		// Required to implicitly cast the dynamic value to a kha.Color
		var borderColor: kha.Color = styleBorder.color;
		uniformValues["borderColor"][bufferIndex * 4 + 0] = borderColor.R;
		uniformValues["borderColor"][bufferIndex * 4 + 1] = borderColor.G;
		uniformValues["borderColor"][bufferIndex * 4 + 2] = borderColor.B;
		uniformValues["borderColor"][bufferIndex * 4 + 3] = borderColor.A * style.opacity;

		var shadowColor: kha.Color = styleShadow.color;
		if (styleShadow.radius == 0) shadowColor = kha.Color.Transparent;
		uniformValues["shadowColors"][bufferIndex * 4 + 0] = shadowColor.R;
		uniformValues["shadowColors"][bufferIndex * 4 + 1] = shadowColor.G;
		uniformValues["shadowColors"][bufferIndex * 4 + 2] = shadowColor.B;
		uniformValues["shadowColors"][bufferIndex * 4 + 3] = shadowColor.A * style.opacity;

		uniformValues["attributes"][bufferIndex * 4 + 0] = styleBorder.size;
		// Todo: Rename shadow radius to width
		uniformValues["attributes"][bufferIndex * 4 + 1] = styleShadow.radius;
		uniformValues["attributes"][bufferIndex * 4 + 2] = styleShadow.falloff;
		uniformValues["attributes"][bufferIndex * 4 + 3] = 0; // Unused

		bufferIndex++;
	}
	#end
}
