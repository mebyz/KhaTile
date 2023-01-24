package koui.elements;

import kha.graphics2.HorTextAlignment;
import kha.graphics2.VerTextAlignment;

import koui.effects.Border;
import koui.utils.TextureAtlas;
import koui.theme.ThemeUtil;

using kha.graphics2.GraphicsExtension;

/**
 * A simple label that displays text.
 *
 * ![Label screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_label.png)
 */
class Label extends Element {
	/** The displayed text. */
	public var text(default, set) = "";
	function set_text(value: String): String {
		koui.utils.FontUtil.loadGlyphsFromStringOptional(value);

		// This setter is called in the constructor when the style isn't set yet
		if (style != null) {
			width = Std.int(ThemeUtil.getFont().width(style.font.size, value));
		}
		return text = value;
	}

	/** Horizontal alignment of the text. */
	public var alignmentHor = HorTextAlignment.TextLeft;
	/** Vertical alignment of the text. */
	public var alignmentVert = VerTextAlignment.TextTop;

	/**
	 * Creates a new `Label` with the given text.
	 *
	 * @param text The text to display
	 * @param alignmentHor Horizontal alignment of the label
	 * @param alignmentVert Vertical alignment of the label
	 */
	public function new(text: String, ?alignmentHor: HorTextAlignment, ?alignmentVert: VerTextAlignment) {
		super();
		this.text = text;

		if (alignmentHor != null) this.alignmentHor = alignmentHor;
		if (alignmentVert != null) this.alignmentVert = alignmentVert;
	}

	override function onTIDChange() {
		if (style.textureBg == "") {
			width = Std.int(ThemeUtil.getFont().width(style.font.size, text));
			height = Std.int(style.font.size);
		} else {
			width = style.atlas.w;
			height = style.atlas.h;
		}
	}

	public override function draw(g: koui.graphics.KGraphics) {
		TextureAtlas.drawFromAtlas(g, this, 1, 1, 0, 0);

		var margin = style.margin;
		var drawAtX = drawX;
		var drawAtY = drawY;

		switch (getAnchorResolved()) {
			case TopLeft:
				drawAtX += margin.left;
			case TopCenter:
				drawAtX = Std.int(drawX + drawWidth / 2 + margin.left);
			case TopRight:
				drawAtX = drawX + drawWidth - margin.right;
			case MiddleLeft:
				drawAtX += margin.left;
				drawAtY = Std.int(drawY + drawHeight / 2);
			case MiddleCenter:
				drawAtX = Std.int(drawX + drawWidth / 2 + margin.left);
				drawAtY = Std.int(drawY + drawHeight / 2);
			case MiddleRight:
				drawAtX = drawX + drawWidth - margin.right;
				drawAtY = Std.int(drawY + drawHeight / 2);
			case BottomLeft:
				drawAtX += margin.left;
				drawAtY = drawY + drawHeight;
			case BottomCenter:
				drawAtX = Std.int(drawX + drawWidth / 2 + margin.left);
				drawAtY = drawY + drawHeight;
			case BottomRight:
				drawAtX = drawX + drawWidth - margin.right;
				drawAtY = drawY + drawHeight;
			default:
		}

		g.drawKAlignedString(text, drawAtX, drawAtY, alignmentHor, alignmentVert, style);
		// Border.draw(g, this);
	}

	override public function toString(): String {
		return 'Element: <${Type.getClassName(Type.getClass(this))}>{Text: "${this.text}"}';
	}
}
