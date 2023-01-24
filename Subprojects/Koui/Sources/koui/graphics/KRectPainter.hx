package koui.graphics;

import kha.Canvas;
import kha.FastFloat;
import kha.Shaders;

import koui.theme.Style;

class KRectPainter extends KPainter {
	public function new(g4: kha.graphics4.Graphics, canvas: Canvas) {
		super(g4, canvas, ["rects", "attributes", "borderColor", "shadowColors"], Shaders.rect_vert, Shaders.rect_frag);
	}

	#if (KOUI_EFFECTS_OFF || KOUI_EFFECTS_SHADOW_OFF)
	private static inline override function init() {}

	@:access(koui.elements.Element)
	public static inline function fillKRect(
			x: FastFloat, y: FastFloat, width: FastFloat, height: FastFloat,
			cornerRadius: Int,
			styleBorder: Dynamic, styleGradient: Dynamic, styleShadow: Dynamic) {
		g2.color = styleGradient.colorBottomRight;
		g2.fillRect(x, y, width, height);
	}
	#else

	@:access(koui.elements.Element)
	public function fillKRect(x: FastFloat, y: FastFloat, width: FastFloat, height: FastFloat, style: Style) {
		// Draw buffer if full
		if (bufferIndex + 1 >= KPainter.bufferSize) drawBuffer();

		var canvasW = canvas.width;
		var screenH = canvas.height;

		var cornerRadius = style.cornerRadius;
		var styleBorder = style.border;
		var styleColor = style.color;
		var styleShadow = style.dropShadow;
		var shadowWidth = styleShadow.radius;

		// Calculate shadow quad positions in window space
		var posLeft = (x - shadowWidth) / canvasW;
		var posRight = (x + width + shadowWidth) / canvasW;
		// Todo: use Image.renderTargetInvertedY
		#if (kha_opengl || kha_webgl)
		var posTop = ((y - shadowWidth)) / screenH;
		var posBottom = ((y + height + shadowWidth)) / screenH;
		#else
		// Invert y axis
		var posTop = (screenH - (y - shadowWidth)) / screenH;
		var posBottom = (screenH - (y + height + shadowWidth)) / screenH;
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

		uniformValues["rects"][bufferIndex * 4 + 0] = x + cornerRadius;
		uniformValues["rects"][bufferIndex * 4 + 1] = x + width - cornerRadius;
		uniformValues["rects"][bufferIndex * 4 + 2] = y + height - cornerRadius;
		uniformValues["rects"][bufferIndex * 4 + 3] = y + cornerRadius;

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
		uniformValues["attributes"][bufferIndex * 4 + 1] = cornerRadius;
		// Todo: Rename shadow radius to width
		uniformValues["attributes"][bufferIndex * 4 + 2] = shadowWidth;
		uniformValues["attributes"][bufferIndex * 4 + 3] = styleShadow.falloff;

		bufferIndex++;
	}
	#end
}
