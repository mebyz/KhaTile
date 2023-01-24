package koui.elements.layouts;

import koui.elements.layouts.Layout.Anchor;

class AnchorPane extends Layout {
	var elements: Array<Element> = new Array();

	public function new(posX: Int, posY: Int, width: Int, height: Int) {
		super(posX, posY, width, height);
		this.defaultAnchor = TopLeft;
	}

	public function add(element: Element, ?anchor: Anchor) {
		element.layout = this;
		if (anchor != null) element.anchor = anchor;

		elements.push(element);

		recalcElement(element);
	};

	public function remove(element: Element) {
		elements.remove(element);
		element.layout = null;
	}

	override function draw(g: koui.graphics.KGraphics) {
		g.pushTranslation(drawX, drawY);

		for (element in elements) {
			renderElement(g, element);
		}

		#if KOUI_DEBUG_LAYOUT
		g.color = Config.DBG_COLOR_ANCHORPANE;
		g.font = Koui.font;
		g.fontSize = 16;
		g.drawLine(0, 0, drawWidth, 0);
		g.drawLine(0, drawHeight, drawWidth, drawHeight);
		g.drawLine(0, 0, 0, drawHeight);
		g.drawLine(drawWidth, 0, drawWidth, drawHeight);
		g.drawString('w: $drawWidth, h: $drawHeight', 0, 0);
		#end

		g.popTransformation();
	};

	public override function resize(width: Int, height: Int) {
		super.resize(width, height);

		for (element in elements) {
			if (needsValidation(element)) {
				recalcElement(element);
			}
		}
	}

	override function getAllElements(): Iterable<Element> {
		return elements;
	}

	public override function getElementAtPosition(x: Int, y: Int): Null<Element> {
		// If the mouse does not hover over this AnchorPane, don't check the
		// contained elements and return `null`.
		if (!this.isAtPosition(x, y)) return null;

		if (absorbEvents) return this;

		// Make coords relative to this layout
		x = x - layoutX;
		y = y - layoutY;

		// Reverse to ensure that the topmost element is selected
		// TODO: Add custom iterator for iterating in reverse (no need to copy data)
		var sortedElements = elements.copy();
		sortedElements.reverse();

		for (element in sortedElements) {
			if (!element.visible) {
				continue;
			}

			var hit = element.getElementAtPosition(x, y);
			if (hit != null) return hit;

			if (element.isAtPosition(x, y)) return element;
		}

		return null;
	}

	public override function elemUpdated(element: Element) {
		recalcElement(element);
	}

	function recalcElement(element: Element) {
		var invalid = calcElementSize(element, this.layoutWidth, this.layoutHeight);

		switch (element.getAnchorResolved()) {
			case TopLeft, MiddleLeft, BottomLeft:
				element.layoutX = element.posX + paddingLeft;
			case TopCenter, MiddleCenter, BottomCenter:
				element.layoutX = Std.int(this.layoutWidth / 2 - element.layoutWidth / 2 + element.posX);
			case TopRight, MiddleRight, BottomRight:
				element.layoutX = this.layoutWidth - element.layoutWidth + element.posX - paddingRight;
			default:
		}

		switch (element.getAnchorResolved()) {
			case TopLeft, TopCenter, TopRight:
				element.layoutY = element.posY + paddingTop;
			case MiddleLeft, MiddleCenter, MiddleRight:
				element.layoutY = Std.int(this.layoutHeight / 2 - element.layoutHeight / 2 + element.posY);
			case BottomLeft, BottomCenter, BottomRight:
				element.layoutY = this.layoutHeight - element.layoutHeight + element.posY - paddingBottom;
			default:
		}

		// Ensure that the child elements of the element are also repositioned
		// if the element is a layout
		// TODO: replace this with translation above, so no resizing
		if (invalid || Std.isOfType(element, Expander)) {
			Layout.resizeIfLayout(element);
		}
	}
}
