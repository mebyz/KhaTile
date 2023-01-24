package koui.elements;

import kha.FastFloat;

import koui.events.EventHandler;
import koui.events.MouseEvent.MouseClickEvent;
import koui.events.MouseEvent.MouseHoverEvent;
import koui.events.ValueChangeEvent;
import koui.theme.ThemeUtil;
import koui.utils.MathUtil;

using kha.graphics2.GraphicsExtension;

/**
 * A slider is an element for controlling a value inside a certain range.
 * Sliders also have an attribute called [`precision`](#precision) that defines
 * the number of decimal places the value can have.
 *
 * ![Slider screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_slider.png)
 *
 * ```haxe
 * // Construct a new Slider with values between 0 and 100
 * var mySlider = new Slider(0, 100);
 *
 * // Accept two decimal places...
 * mySlider.precision = 2:
 *
 * // ...or only accept whole numbers
 * mySlider.precision = 0;
 *
 * // Set the current value to 32
 * mySlider.value = 32;
 * ```
 *
 * @see [Wiki: Slider](https://gitlab.com/koui/Koui/-/wikis/Documentation/Elements/Slider)
 */
class Slider extends Element implements I_Range<FastFloat> {
	/**
	 * The current value of this element.
	 */
	public var value(default, set): FastFloat = 0.0;

	/**
	 * The number of decimal places the value of this element has.
	 */
	public var precision = 0;

	/**
	 * The direction this slider is oriented to.
	 */
	public var orientation(default, set): SliderOrientation;

	/**
	 * The minimum value of this slider. Must not be bigger than
	 * `Slider.maxValue`.
	 */
	public var minValue(default, set): FastFloat = 0.0;
	function set_minValue(value: FastFloat) {
		this.minValue = value;
		updateMinMax();
		return this.minValue;
	}

	/**
	 * The maximum value of this slider. Must not be bigger than
	 * `Slider.minValue`.
	 */
	public var maxValue(default, set): FastFloat = 1.0;
	function set_maxValue(value: FastFloat) {
		this.maxValue = value;
		updateMinMax();
		return this.maxValue;
	}

	var isHovered = false;
	var isClicked = false;
	var clickOffset = 0;

	var handleSize = 0;

	var cElemHandle: Panel;

	/**
	 * Creates a new `Slider` with the given range.
	 *
	 * @param minValue The lower bound of the slider's range
	 * @param maxValue The upper bound of the slider's range
	 * @param orientation Override the orientation
	 */
	public function new(minValue: FastFloat, maxValue: FastFloat, orientation = SliderOrientation.Right) {
		@:bypassAccessor this.orientation = orientation;
		@:bypassAccessor this.minValue = minValue;
		@:bypassAccessor this.maxValue = maxValue;
		validateMinMax();

		super();

		this.autoRenderChildren = false;

		if (maxValue - minValue < 10) precision = 1;

		#if !KOUI_EVENTS_OFF
		addEventListener(MouseHoverEvent, _onHover);
		addEventListener(MouseClickEvent, _onClick);
		#end
	}

	override function onBuild() {
		cElemHandle = new Panel();
		addChild(cElemHandle);
	}

	override function initStyle() {
		requireStates(["hover", "click"]);

		cElemHandle.setTID('${this.tID}_inner');
		cElemHandle.requireStates(["hover", "click"]);
	}

	override function onTIDChange() {
		ThemeUtil.requireOptGroups(["slider"]);

		if (style.textureBg == "") {
			width = style.size.width;
			height = style.size.height;
		}
		else {
			width = style.atlas.w;
			height = style.atlas.h;
		}

		cElemHandle.setTID('${this.tID}_inner');
		updateHandleSize();
	}

	function updateHandleSize() {
		if (isHorizontal()) {
			cElemHandle.setSize(style.slider.buttonWidth, height);
		} else {
			cElemHandle.setSize(width, style.slider.buttonWidth);
		}
		handleSize = style.slider.buttonWidth;
	}

	function updateHandlePosition() {
		if (isHorizontal()) {
			cElemHandle.posX = Std.int(calculateSliderPosition());
			cElemHandle.posY = 0;
		}
		else {
			cElemHandle.posX = 0;
			cElemHandle.posY = Std.int(calculateSliderPosition());
		}
	}

	#if !KOUI_EVENTS_OFF
	function _onHover(event: MouseHoverEvent) {
		switch (event.getState()) {
			case HoverStart: isHovered = true;
			case HoverActive:
			case HoverEnd: isHovered = false;
		}
	}

	function _onClick(event: MouseClickEvent) {
		if (event.mouseButton != Left) return;

		switch (event.getState()) {
			case ClickStart:
				isClicked = true;
				clickOffset = isHorizontal() ? this.getLayoutOffset()[0] : this.getLayoutOffset()[1];
				EventHandler.block(this);

			case ClickHold:
				if (isHorizontal()) {
					@:bypassAccessor value = MathUtil.mapToRange(
						EventHandler.mouseX + clickOffset,
						drawX + handleSize / 2, drawX + drawWidth - handleSize / 2,
						minValue, maxValue);

					if (orientation == Left) {
						@:bypassAccessor value = maxValue - value;
					}
				}
				else {
					@:bypassAccessor value = MathUtil.mapToRange(
						EventHandler.mouseY + clickOffset,
						drawY + handleSize / 2, drawY + drawHeight - handleSize / 2,
						minValue, maxValue);

					if (orientation == Up) {
						@:bypassAccessor value = maxValue - value;
					}
				}

				// Now set via accessor
				value = MathUtil.clamp(value, minValue, maxValue);

			case ClickEnd, ClickCancelled:
				isClicked = false;
				EventHandler.unblock();
		}
	}
	#end

	function set_value(val: FastFloat): FastFloat {
		this.value = MathUtil.clamp(val, minValue, maxValue);
		updateHandlePosition();

		Event.dispatch(new ValueChangeEvent(this));
		return value;
	}

	function set_orientation(val: SliderOrientation): SliderOrientation {
		this.orientation = val;
		updateHandleSize();
		updateHandlePosition();
		return val;
	}

	override function draw(g: koui.graphics.KGraphics) {
		var horizontal = isHorizontal();

		// =====================================================================
		// Background
		// =====================================================================
		var imageName = style.textureBg;
		if (imageName == "") {
			if (isClicked) setContextState("click");
			else if (isHovered) setContextState("hover");
			else resetContext();

			g.fillKRect(drawX, drawY, drawWidth, drawHeight, style);
		}

		else {
			var atlasX: Int = style.atlas.x;
			var atlasY: Int = style.atlas.y;
			var atlasW: Int = style.atlas.w;
			var atlasH: Int = style.atlas.h;

			width = atlasW;
			height = atlasH;
			drawWidth = atlasW;
			drawHeight = atlasH;

			g.color = 0xffffffff;
			g.drawSubImage(kha.Assets.images.get(imageName), drawX, drawY, atlasX, atlasY, atlasW, atlasH);
			setContextState("default");
		}

		// =====================================================================
		// Handle
		// =====================================================================
		renderChildren(g, this);

		// =====================================================================
		// Text
		// =====================================================================
		setContextElement("");

		g.color = style.color.text;
		g.font = ThemeUtil.getFont();
		g.fontSize = style.font.size;

		var textPosY = Std.int(drawY + drawHeight / 2);

		var tOffsetX = style.slider.textOffsetX;
		var tOffsetY = style.slider.textOffsetY;

		if (style.slider.showRange) {
			if (horizontal) {
				var textLeft = orientation == Right ? "" + minValue : "" + maxValue;
				var textRight = orientation == Right ? "" + maxValue : "" + minValue;
				g.drawKAlignedString(textLeft, drawX + tOffsetX, textPosY + tOffsetY, TextLeft, TextMiddle, style);
				g.drawKAlignedString(textRight, drawX + drawWidth + tOffsetX, textPosY + tOffsetY, TextRight, TextMiddle, style);
			}
			else {
				var textTop = orientation == Down ? "" + minValue : "" + maxValue;
				var textBottom = orientation == Down ? "" + maxValue : "" + minValue;
				g.drawKAlignedString(textTop, drawX + drawWidth / 2 + tOffsetX, drawY + tOffsetY, TextCenter, TextTop, style);
				g.drawKAlignedString(textBottom, drawX + drawWidth / 2 + tOffsetX, drawY + drawHeight + tOffsetY, TextCenter, TextBottom, style);
			}
		}

		if (style.slider.showValue) {
			if (horizontal) {
				g.drawKAlignedString("" + MathUtil.roundPrecision(value, this.precision), drawX + drawWidth / 2 + tOffsetX, textPosY + tOffsetY, TextCenter, TextMiddle, style);
			}
			else {
				g.drawKAlignedString("" + MathUtil.roundPrecision(value, this.precision), drawX + drawWidth / 2 + tOffsetX, drawY + drawHeight / 2 + tOffsetY, TextCenter, TextMiddle, style);
			}
		}
	}

	function calculateSliderPosition(): FastFloat {
		return switch (orientation) {
			case Up:
				MathUtil.mapToRange(value, minValue, maxValue, drawHeight - handleSize, 0);
			case Down:
				MathUtil.mapToRange(value, minValue, maxValue, 0, drawHeight - handleSize);
			case Right:
				MathUtil.mapToRange(value, minValue, maxValue, 0, drawWidth - handleSize);
			case Left:
				MathUtil.mapToRange(value, minValue, maxValue, drawWidth - handleSize, 0);
		}
	}

	/**
	 * Quickly check if this slider is oriented horizontally (left or right).
	 */
	public inline function isHorizontal() {
		return orientation == Left || orientation == Right;
	}

	inline function validateMinMax() {
		if (minValue > maxValue) {
			Log.error("Slider: minValue must not be larger than maxValue!");
		}
	}

	inline function updateMinMax() {
		validateMinMax();

		final prev = value;
		@:bypassAccessor value = MathUtil.clamp(value, minValue, maxValue);
		updateHandlePosition();
		if (value != prev) {
			Event.dispatch(new ValueChangeEvent(this));
		}
	}
}

enum abstract SliderOrientation(Int) {
	var Up;
	var Down;
	var Left;
	var Right;
}
