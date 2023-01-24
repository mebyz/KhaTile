package koui.elements;

import koui.events.CheckboxEvent;
import koui.events.MouseEvent.MouseClickEvent;
import koui.events.MouseEvent.MouseHoverEvent;
import koui.theme.ThemeUtil;
import koui.utils.ElementMatchBehaviour.TypeMatchBehaviour;
import koui.utils.TextureAtlas;

using kha.graphics2.GraphicsExtension;

/**
 * A checkbox is a button that represents an option, it can either be switched
 * on or off. It has a text label that is describing the function of the
 * checkbox.
 *
 * ![Checkbox screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_checkbox.png)
 *
 * ```haxe
 * // Construct a new Checkbox with the label "Checkbox"
 * var myCheckbox = new Checkbox("Checkbox");
 * // Make the checkbox checked (select it)
 * myCheckbox.isChecked = true;
 * ```
 *
 * @see `RadioButton`
 */
class Checkbox extends Element {
	/**
	 * The label of this checkbox.
	 */
	public var text(default, set) = "";
	/**
	 * `true` when this checkbox is active, otherwise `false`.
	 */
	public var isChecked = false;

	var onCheckedFunc: Void->Void = () -> {};
	var onUncheckedFunc: Void->Void = () -> {};

	var paddingX: Int = 0;
	var paddingY: Int = 0;

	var checkSize: Int;

	var isHovered = false;
	var isClicked = false;

	/**
	 * Create a new `Checkbox` element.
	 */
	public function new(text: String) {
		super();

		this.text = text;

		#if !KOUI_EVENTS_OFF
		addEventListener(MouseHoverEvent, _onHover);
		addEventListener(MouseClickEvent, _onClick);
		#end
	}

	override function onBuild() {
		var label = new Label(text);
		label.alignmentHor = TextLeft;
		label.alignmentVert = TextMiddle;
		addChild(label);

		var checkSquare = new Panel();
		addChild(checkSquare);
	}

	override function initStyle() {
		requireStates(["hover", "click"]);
		requireStates(["hover", "click"], "inner");
		requireStates(["hover", "click"], "inner_checked");

		var label: Label = getChild(new TypeMatchBehaviour(Label));
		label.setTID(this.tID);
		label.requireStates(["hover", "click"]);

		var checkSquare: Panel = getChild(new TypeMatchBehaviour(Panel));
		checkSquare.setTID('${this.tID}_inner');
		checkSquare.requireStates(["hover", "click"]);
		checkSquare.requireStates(["hover", "click"], "checked");
	}

	override function onResize() {
		var label: Label = getChild(new TypeMatchBehaviour(Label));

		var offsetLeft = paddingX * 2 + checkSize;
		label.setPosition(drawX + offsetLeft, Std.int(drawY + drawHeight / 2));

		var checkSquare: Panel = getChild(new TypeMatchBehaviour(Panel));
		checkSquare.setPosition(paddingX, Std.int((drawHeight - checkSize) / 2));
		checkSquare.setSize(checkSize, checkSize);
	}

	function set_text(value: String): String {
		var label: Label = getChild(new TypeMatchBehaviour(Label));
		label.text = value;

		return this.text = value;
	}

	override function onTIDChange() {
		ThemeUtil.requireOptGroups(["checkbox"]);

		width = style.size.width;
		height = style.size.height;

		setContextElement("inner");

		checkSize = style.size.height;
		paddingY = Std.int((height - checkSize) / 2);

		setContextElement("");

		paddingX = style.checkbox.useAutoPadding ? paddingY : style.padding.left;

		onResize();
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
			case ClickStart: isClicked = true;
			case ClickHold:
			case ClickEnd:
				isClicked = false;
				isChecked = !isChecked;
				Event.dispatch(new CheckboxEvent(this, isChecked ? Checked : Unchecked));
				var checkSquare: Panel = getChild(new TypeMatchBehaviour(Panel));
				checkSquare.setContextElement(isChecked ? "checked" : "");
			case ClickCancelled:
				isClicked = false;
		}
	}
	#end

	override public function draw(g: koui.graphics.KGraphics) {
		if (isClicked) setContextState("click");
		else if (isHovered) setContextState("hover");
		else resetContextState();

		if (style.textureBg != "") {
			paddingY = Std.int((drawHeight - style.atlas.h) / 2);
		}

		var atlasOffsetX = isChecked ? 1 : 0;
		var atlasOffsetY = isClicked ? 2 : (isHovered ? 1 : 0);

		if (!TextureAtlas.drawFromAtlas(g, this, 2, 3, atlasOffsetX, atlasOffsetY, drawX + paddingX, drawY + paddingY)) {
			g.fillKRect(drawX, drawY, drawWidth, drawHeight, style);
		}
	}

	/**
		Run the given callback when the checkbox was checked.
	**/
	public inline function onChecked(callback: Void->Void) {
		onCheckedFunc = callback;
	}

	/**
		Run the given callback when the checkbox was unchecked.
	**/
	public inline function onUnchecked(callback: Void->Void) {
		onUncheckedFunc = callback;
	}
}
