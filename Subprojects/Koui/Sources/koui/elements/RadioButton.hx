package koui.elements;

import koui.events.CheckboxEvent;
import koui.events.MouseEvent.MouseClickEvent;
import koui.theme.ThemeUtil;
import koui.utils.ElementMatchBehaviour.TypeMatchBehaviour;
import koui.utils.RadioGroup;
import koui.utils.TextureAtlas;

using kha.graphics2.GraphicsExtension;

/**
 * A radio button is a special kind of checkbox that is used to select exactly
 * one option from a set of options. Radio buttons belong to a `RadioGroup` that
 * holds all related radio buttons from which only one option can be selected.
 *
 * ![RadioButton screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_radiobutton.png)
 *
 * @see `RadioGroup`
 * @see `Checkbox`
 */
class RadioButton extends Checkbox {
	/**
	 * The `RadioGroup` this radio button belongs to.
	 */
	public var group: RadioGroup;

	/**
	 * Creates a new `RadioButton`.
	 * @param group The `RadioGroup` this radio button belongs to.
	 * @param label The label of this radio button.
	 */
	public function new(group: RadioGroup, label: String) {
		super(label);

		#if !KOUI_EVENTS_OFF
		addEventListener(CheckboxEvent, _onCheckChange);
		#end

		this.group = group;
		this.group.add(this);
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

	#if !KOUI_EVENTS_OFF
	override function _onClick(event: MouseClickEvent) {
		if (event.mouseButton != Left) return;

		switch (event.getState()) {
			case ClickStart: isClicked = true;
			case ClickHold:
			case ClickEnd:
				isClicked = false;
				if (!isChecked) {
					group.setActiveButton(this);
				}
			case ClickCancelled:
				isClicked = false;
		}
	}

	function _onCheckChange(event: CheckboxEvent) {
		var checkSquare: Panel = getChild(new TypeMatchBehaviour(Panel));
		checkSquare.setContextElement(event.getState() == Checked ? "checked" : "");
	}
	#end

	public override function draw(g: koui.graphics.KGraphics) {
		setContextElement("");
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
}
