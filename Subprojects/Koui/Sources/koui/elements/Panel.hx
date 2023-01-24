package koui.elements;

/**
 * A panel is a rectangle that is mostly used as a background behind some
 * content that is visually grouped together.
 *
 * ![Panel screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_panel.png)
 */
class Panel extends Element {
	/**
	 * Create a new `Panel` element.
	 */
	public function new() {
		super();
	}

	override public function draw(g: koui.graphics.KGraphics) {
		g.fillKRect(drawX, drawY, drawWidth, drawHeight, style);
	}
}
