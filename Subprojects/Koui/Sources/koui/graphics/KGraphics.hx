package koui.graphics;

import kha.Canvas;
import kha.FastFloat;
import kha.graphics2.GraphicsExtension;
import kha.graphics2.HorTextAlignment;
import kha.graphics2.VerTextAlignment;
import kha.graphics4.Graphics2; // PipelineCache
import kha.graphics4.PipelineState;
import kha.math.FastVector2;
import koui.theme.Style;



/**
 * Custom graphics class for Koui.
 */
class KGraphics extends kha.graphics4.Graphics2 {
	var kRectPainter: KRectPainter;
	var kCirclePainter: KCirclePainter;

	static var textPipeline: PipelineState;

	override public function new(canvas: Canvas) {
		super(canvas);

		kRectPainter = new KRectPainter(g, canvas);
		kCirclePainter = new KCirclePainter(g, canvas);

		kRectPainter.init();
		kCirclePainter.init();
	}

	public static function initTextPipeline() {
		var textVS = kha.graphics4.Graphics2.createTextVertexStructure();
		textPipeline = kha.graphics4.Graphics2.createTextPipeline(textVS);
		textPipeline.alphaBlendSource = BlendOne;
		textPipeline.alphaBlendDestination = InverseSourceAlpha;
		textPipeline.blendSource = SourceAlpha;
		textPipeline.blendDestination = InverseSourceAlpha;
		textPipeline.blendOperation = Add;
		textPipeline.compile();
	}

	/**
	 * Draw a filled rectangle with the given style. The drawing takes drop
	 * shadows, gradients, borders and rounded corners into account.
	 */
	public function fillKRect(x: FastFloat, y: FastFloat, width: FastFloat, height: FastFloat, style: Style) {
		if (style.border.nineSlice) {
			// Use atlas coordinates as inner rectangle
			var atl = style.atlas;
			var innerRect = new Rect(atl.x, atl.y, atl.w, atl.h);

			var texture = kha.Assets.images.get(style.textureBg);
			if (texture == null) {
				return;
			}

			var slices = NineSlice.createSlices(innerRect, texture.width, texture.height, width, height);
			var imgSlices = slices[0];
			var elemSlices = slices[1];

			for (i in 0...9) {
				var imgSlice = imgSlices[i];
				var elemSlice = elemSlices[i];

				this.drawScaledSubImage(
					texture,
					imgSlice.left, imgSlice.top, imgSlice.width, imgSlice.height,
					x + elemSlice.left, y + elemSlice.top, elemSlice.width, elemSlice.height);
			}
		}
		else {
			// Apply transformations
			var p = this.transformation.multvec(new FastVector2(x, y));

			coloredPainter.end();
			imagePainter.end();
			textPainter.end();
			kCirclePainter.end();
			kRectPainter.fillKRect(p.x, p.y, width, height, style);
		}
	}

	/**
	 * Draw a filled circle with the given style. The drawing takes drop
	 * shadows, gradients and borders into account.
	 */
	public function fillKCircle(cx: FastFloat, cy: FastFloat, radius: FastFloat, style: Style) {
		// Apply transformations
		var p = transformation.multvec(new FastVector2(cx, cy));

		coloredPainter.end();
		imagePainter.end();
		textPainter.end();
		kRectPainter.end();
		kCirclePainter.fillKCircle(p.x, p.y, radius, style);
	}

	/**
	 * Draw an aligned string with the given style. The drawing takes the font,
	 * font size, color and text shadow specified by the style into account.
	 *
	 * @see `kha.graphics2.GraphicsExtension.drawAlignedString()`
	 */
	public function drawKAlignedString(text: String, x: FastFloat, y: FastFloat, horAlign: HorTextAlignment, verAlign: VerTextAlignment, style: Style) {
		this.pipeline = textPipeline;

		this.fontSize = style.font.size;
		this.font = kha.Assets.fonts.get(style.font.family);

		// TODO: replace by custom fragment shader to support blurred shadows
		if (style.textShadow != null) {
			this.color = style.textShadow.color;
			GraphicsExtension.drawAlignedString(this, text, x + style.textShadow.offsetX, y + style.textShadow.offsetY, horAlign, verAlign);
		}

		this.color = style.color.text;
		GraphicsExtension.drawAlignedString(this, text, x, y, horAlign, verAlign);

		this.pipeline = null;

		if (style.font.underlineThickness != 0) {
			var width = font.width(fontSize, text);
			var height = font.height(fontSize);

			var offsetX: FastFloat = switch (horAlign) {
				case TextCenter: -width * 0.5;
				case TextRight: -width;
				default: 0.0;
			}

			var offsetY: FastFloat = switch (verAlign) {
				case TextMiddle: height * 0.5;
				case TextTop: height;
				default: 0.0;
			}

			fillRect(x + offsetX, y + offsetY, width, style.font.underlineThickness);
		}
	}

	// =========================================================================
	// Overrides to ensure correct drawing order
	// =========================================================================

	public override function flush() {
		super.flush();
		kRectPainter.end();
		kCirclePainter.end();
	}

	public override function drawString(text: String, x: FastFloat, y: FastFloat) {
		kRectPainter.end();
		kCirclePainter.end();
		super.drawString(text, x, y);
	}

	public override function drawCharacters(text: Array<Int>, start: Int, length: Int, x: FastFloat, y: FastFloat) {
		kRectPainter.end();
		kCirclePainter.end();
		super.drawCharacters(text, start, length, x, y);
	}

	public override function drawRect(x: FastFloat, y: FastFloat, width: FastFloat, height: FastFloat, strength: FastFloat = 1.0) {
		kRectPainter.end();
		kCirclePainter.end();
		super.drawRect(x, y, width, height, strength);
	}

	public override function fillRect(x: FastFloat, y: FastFloat, width: FastFloat, height: FastFloat) {
		kRectPainter.end();
		kCirclePainter.end();
		super.fillRect(x, y, width, height);
	}

	public override function drawLine(x1: FastFloat, y1: FastFloat, x2: FastFloat, y2: FastFloat, strength: FastFloat = 1.0) {
		kRectPainter.end();
		kCirclePainter.end();
		super.drawLine(x1, y1, x2, y2, strength);
	}

	public override function fillTriangle(x1: FastFloat, y1: FastFloat, x2: FastFloat, y2: FastFloat, x3: FastFloat, y3: FastFloat) {
		kRectPainter.end();
		kCirclePainter.end();
		super.fillTriangle(x1, y1, x2, y2, x3, y3);
	}

	// No need to extend other image functions, they are all based on this
	public override function drawScaledSubImage(
			img: kha.Image,
			sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat,
			dx: FastFloat, dy: FastFloat, dw: FastFloat, dh: FastFloat) {

		kRectPainter.end();
		kCirclePainter.end();
		super.drawScaledSubImage(img, sx, sy, sw, sh, dx, dy, dw, dh);
	}

	private override function setProjection(): Void {
		super.setProjection();

		// Todo: set projections for custom painters
	}

	override public function setPipeline(pipeline: PipelineState) {
		if (pipeline == lastPipeline) return;

		lastPipeline = pipeline;
		flush();
		if (pipeline == null) {
			imagePainter.pipeline = null;
			coloredPainter.pipeline = null;
			textPainter.pipeline = null;
			kRectPainter.pipelineCache = null;
			kCirclePainter.pipelineCache = null;
		}
		else {
			var cache = pipelineCache[pipeline];
			if (cache == null) {
				cache = new SimplePipelineCache(pipeline, true);
				pipelineCache[pipeline] = cache;
			}
			imagePainter.pipeline = cache;
			coloredPainter.pipeline = cache;
			textPainter.pipeline = cache;
			kRectPainter.pipelineCache = cache;
			kCirclePainter.pipelineCache = cache;
		}
	}
}
