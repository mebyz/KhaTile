package koui.elements;

import kha.FastFloat;

import koui.utils.ElementMatchBehaviour.TypeMatchBehaviour;
import koui.utils.Log;
import koui.utils.MathUtil;
import koui.theme.ThemeUtil;

using kha.graphics2.GraphicsExtension;

/**
 * Displays a progress bar.
 *
 * ![Progressbar screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_progressbar.png)
 *
 * ```haxe
 * // Construct a new Progressbar with a value range of [0, 200].
 * var myProgressbar = new Progressbar(0, 200);
 *
 * // Display the percentage of progress
 * myProgressbar.label = "Progress: ::percentage::%"
 *
 * // Set the value to 36, which is 18% of the value range
 * myProgressbar.value = 36;
 * ```
 */
class Progressbar extends Element implements I_Range<FastFloat> {
	/**
	 * The current value (in the interval `[minValue, maxValue]`).
	 */
	public var value(default, set): FastFloat = 0.0;

	/**
	 * The current progress (in the interval `[0, 1]`).
	 */
	public var progress(default, null): FastFloat = 0.0;

	/**
	 * The label of this progress bar.
	 *
	 * > Tip: Use Haxe's [template system](https://haxe.org/manual/std-template.html)
	 * > with [`::value::`](#value), [`::progress::`](#progress),
	 * > `::percentage::` (progress * 100 as integer value),
	 * > [`::minValue::`](#minValue) or [`::maxValue::`](#maxValue)! Other
	 * > template variables are not supported.
	 *
	 * ```haxe
	 * myProgressbar.label = "Progress: ::percentage::%";
	 * ```
	 *
	 * @see [`precision`](#precision)
	 */
	public var text(default, set) = "";

	/**
	 * The amount of decimal places of the value of this progress bar. Used only
	 * for displaying the label. The value itself is not changed by this
	 * variable. If you need to change the value to this precision, use
	 * `MathUtil.roundPrecision()`.
	 *
	 * @see `MathUtil.roundPrecision()`
	 */
	public var precision = 0;

	/**
	 * The smallest possible value of this progress bar.
	 */
	public var minValue(default, set): FastFloat = 0.0;
	/**
	 * The largest possible value of this progress bar.
	 */
	public var maxValue(default, set): FastFloat = 1.0;


	var paddingX = 0;
	var paddingY = 0;
	var orientation = "right";

	/**
	 * Create a new `Progressbar` with the given value range.
	 */
	public function new(minValue: FastFloat = 0.0, maxValue: FastFloat = 1.0) {
		super();

		requireContextElement("inner");

		if (maxValue < minValue) {
			Log.error("Progressbar: maxValue must be larger than minValue!");
		}

		this.minValue = this.value = minValue;
		this.maxValue = maxValue;
	}

	override function onBuild() {
		var label = new Label(text);
		label.alignmentHor = TextCenter;
		label.alignmentVert = TextMiddle;
		label.requireStates(["hover", "click"]);
		label.setTID(this.tID);

		addChild(label);
	}

	override function onResize() {
		var label: Label = getChild(new TypeMatchBehaviour(Label));

		// TODO: Add alignments
		label.setPosition(Std.int(drawWidth / 2), Std.int(drawHeight / 2));
	}

	function set_text(txt: String): String {
		this.text = txt;
		this.value = value; // Trigger re-calculation of label text

		return this.text;
	}

	@:dox(hide)
	public function set_value(value: FastFloat) {
		progress = MathUtil.mapToRange(value, minValue, maxValue, 0, 1);

		var label: Label = getChild(new TypeMatchBehaviour(Label));
		label.text = new haxe.Template(text).execute({
			progress: progress,
			percentage: Std.int(progress * 100),
			value: MathUtil.roundPrecision(value, precision),
			minValue: minValue,
			maxValue: maxValue
		});
		return this.value = value;
	}

	@:dox(hide)
	public function set_minValue(minValue: FastFloat) {
		if (minValue > maxValue) {
			Log.error("Progressbar: minValue must be smaller than maxValue!");
		}

		return this.minValue = minValue;
	}

	@:dox(hide)
	public function set_maxValue(maxValue: FastFloat) {
		if (maxValue < minValue) {
			Log.error("Progressbar: maxValue must be larger than minValue!");
		}

		return this.maxValue = maxValue;
	}

	override function onTIDChange() {
		width = style.size.width;
		height = style.size.height;

		paddingX = style.padding.left;
		paddingY = style.padding.top;
		orientation = style.orientation;
	}

	override public function draw(g: KGraphics) {
		setContextElement("");
		g.fillKRect(drawX, drawY, drawWidth, drawHeight, style);

		setContextElement("inner");
		switch (orientation) {
			case "right":
				var progressWidth: FastFloat = (drawWidth - paddingX * 2) * progress;
				g.fillKRect(drawX + paddingX, drawY + paddingY, progressWidth, drawHeight - paddingY * 2, style);

			case "left":
				var progressWidth: FastFloat = (drawWidth - paddingX * 2) * progress;
				g.fillKRect(drawX + paddingX + drawWidth - progressWidth, drawY + paddingY, progressWidth, drawHeight - paddingY * 2, style);

			case "bottom":
				var heightProgress: FastFloat = (drawHeight - paddingY * 2) * progress;
				g.fillKRect(drawX + paddingX, drawY + paddingY, drawWidth - paddingX * 2, heightProgress, style);

			case "up":
				var heightProgress: FastFloat = (drawHeight - paddingY * 2) * progress;
				g.fillKRect(drawX + paddingX, drawY + paddingY + drawHeight - heightProgress,  drawWidth - paddingX * 2, heightProgress, style);
		}
	}
}
