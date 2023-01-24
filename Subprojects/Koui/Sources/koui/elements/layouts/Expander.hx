package koui.elements.layouts;

class Expander extends Layout {
	/**
	 * The spacing between elements in this layout.
	 */
	public var spacing = 0;

	/**
	 * The direction in which the expander grows.
	 */
	public var direction(default, set): ExpanderDirection;
	function set_direction(value: ExpanderDirection) {
		this.direction = value;
		invalidateLayout();
		return this.direction;
	}

	var elements: Array<Element> = new Array();

	/**
	 * Create a new Expander layout. Depending on the direction, either the
	 * given `width` or `height` is ignored.
	 */
	public function new(posX: Int, posY: Int, width: Int, height: Int, direction: ExpanderDirection) {
		super(posX, posY, width, height);

		this.direction = direction;
	}

	/**
	 * Add an element to the column at the given index. If the index is not
	 * given (`null`), the element is added to the growing end of the layout.
	 *
	 * If `element` is `null`, nothing happens.
	 */
	public function add(element: Element, ?index: Int) {
		if (element == null) { return; }

		element.layout = this;
		index == null ? elements.push(element) : elements.insert(index, element);
		invalidateLayout();
	}

	public inline function remove(element: Element) {
		this.elements.remove(element);
		element.layout = null;
		invalidateLayout();
	}

	public inline function removeByIndex(index: Int) {
		elements[index].layout = null;
		this.elements.splice(index, 1);
		invalidateLayout();
	}

	public override function resize(width: Int, height: Int) {
		super.resize(width, height);
		recalcSize(false);
	}

	public override function elemUpdated(element: Element) {
		invalidateLayout();
	}

	function recalcSize(invalidate = true) {
		var first = true;

		switch (direction) {
			case DOWN, UP:
				layoutHeight = paddingTop;

				for (i in 0...elements.length) {
					var element = (direction == DOWN ? elements[i] : elements[elements.length - 1 - i]);

					first ? first = false : layoutHeight += spacing;

					element.layoutX = element.posX + paddingLeft;
					element.layoutY = element.posY + layoutHeight;

					// Correct the element's width
					var invalid = calcElementSize(element, this.layoutWidth, element.layoutHeight);
					if (invalid || Std.isOfType(element, Expander)) {
						Layout.resizeIfLayout(element);
					}

					layoutHeight += element.drawHeight;
				}

				layoutHeight += paddingBottom;

			case LEFT, RIGHT:
				layoutWidth = paddingLeft;

				for (i in 0...elements.length) {
					var element = (direction == RIGHT ? elements[i] : elements[elements.length - 1 - i]);

					first ? first = false : layoutWidth += spacing;

					element.layoutX = element.posX + layoutWidth;
					element.layoutY = element.posY + paddingTop;

					var invalid = calcElementSize(element, element.layoutWidth, this.layoutHeight);
					if (invalid || Std.isOfType(element, Expander)) {
						Layout.resizeIfLayout(element);
					}

					layoutWidth += element.drawWidth;
				}

				layoutWidth += paddingRight;
		}

		if (invalidate) {
			invalidateLayout();
		}
	}

	public override function draw(g: koui.graphics.KGraphics) {
		g.pushTranslation(drawX, drawY);

		for (element in elements) {
			renderElement(g, element);
		}

		#if KOUI_DEBUG_LAYOUT
		g.color = Config.DBG_COLOR_EXPANDER;
		g.font = Koui.font;
		g.fontSize = 16;
		g.drawLine(0, 0, drawWidth, 0);
		g.drawLine(0, drawHeight, drawWidth, drawHeight);
		g.drawLine(0, 0, 0, drawHeight);
		g.drawLine(drawWidth, 0, drawWidth, drawHeight);
		g.drawString('w: $drawWidth, h: $drawHeight', 0, 0);
		#end

		g.popTransformation();
	}

	public override function getElementAtPosition(x: Int, y: Int): Null<Element> {
		// If the mouse is not over this layout, don't check the contained
		// elements and return `null`.
		if (!this.isAtPosition(x, y)) return null;

		if (absorbEvents) return this;

		// Make coords relative to this layout
		x = x - layoutX;
		y = y - layoutY;

		// Iterate in reverse to ensure that the first drawn objects are the
		// ones that are checked last.
		for (idx in 1 - elements.length...1) {
			// idx can be row or column
			var element = elements[-idx];

			if (!element.visible) continue;

			if (Std.isOfType(element, Layout)) {
				var hit = cast(element, Layout).getElementAtPosition(x, y);
				if (hit != null) return hit;

				continue;
			}

			if (element.isAtPosition(x, y)) return element;
		}

		return null;
	}
}

/**
 * The direction the Expander grows in.
 *
 * @see `koui.elements.layouts.Expander`
 */
enum abstract ExpanderDirection(Int) {
	final UP;
	final DOWN;
	final LEFT;
	final RIGHT;
}
