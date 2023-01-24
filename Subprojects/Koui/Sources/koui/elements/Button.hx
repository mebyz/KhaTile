package koui.elements;

import koui.events.MouseEvent.MouseHoverEvent;
import koui.events.MouseEvent.MouseClickEvent;
import koui.utils.TextureAtlas;

using kha.graphics2.GraphicsExtension;

/**
	A button is an element that performs an action when clicked. It has a text
	label that is describing the function of the button.

	![Button screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_button.png)

	```haxe
	// Construct a new Button with the label "Quit"
	var myButton = new Button("Quit");

	myButton.addEventListener(MouseClickEvent, (event: MouseClickEvent) -> {
	    // If the left mouse button is released over the button, quit the application
	    if (event.mouseButton == Left && event.getState() == ClickEnd) {
	        kha.System.stop();
	    }
	});
	```
**/
class Button extends Element {
	/**
		The label of this button.
	**/
	public var text(default, set) = "";

	/**
		The icon of this button, can be `null`.
	**/
	public var icon(default, set): Null<kha.Image>;

	var cElemLabel: Label;
	var cElemIcon: ImagePanel;

	var isHovered = false;
	var isClicked = false;

	/**
	 * Create a new `Button` element.
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
		cElemLabel = new Label(text);
		cElemLabel.alignmentHor = TextCenter;
		cElemLabel.alignmentVert = TextMiddle;

		addChild(cElemLabel);

		cElemIcon = new ImagePanel(null);
	}

	override function initStyle() {
		this.requireStates(["hover", "click"]);
		cElemLabel.requireStates(["hover", "click"]);
		cElemLabel.setTID(this.tID);
		cElemIcon.requireStates(["hover", "click"]);
	}

	override function onResize() {
		// TODO: Add alignments
		cElemLabel.setPosition(Std.int(drawWidth / 2), Std.int(drawHeight / 2));

		var padding = Std.int((drawHeight - cElemIcon.layoutHeight) / 2);
		cElemIcon.setPosition(padding, padding);
	}

	function set_text(value: String): String {
		cElemLabel.text = value;

		return this.text = value;
	}

	function set_icon(img: Null<kha.Image>): Null<kha.Image> {
		if (icon != null && img == null) {
			removeChild(cElemIcon);
		} else if (icon == null && img != null) {
			addChild(cElemIcon);
		}
		if (img != null) {
			cElemIcon.image = img;
			onResize();  // Take potentially different icon size into account
		}
		return this.icon = img;
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
			case ClickEnd, ClickCancelled: isClicked = false;
		}
	}
	#end

	override function onTIDChange() {
		if (style.textureBg == "") {
			width = style.size.width;
			height = style.size.height;
		} else {
			width = style.atlas.w;
			height = style.atlas.h;
		}
	}

	override public function draw(g: koui.graphics.KGraphics) {
		if (isClicked) setContextState("click");
		else if (isHovered) setContextState("hover");
		else resetContextState();

		if (!TextureAtlas.drawFromAtlas(g, this)) {
			g.fillKRect(drawX, drawY, drawWidth, drawHeight, style);
		}
	}

	override public function toString(): String {
		return 'Element: <${Type.getClassName(Type.getClass(this))}>{Label: "${this.text}"}';
	}
}
