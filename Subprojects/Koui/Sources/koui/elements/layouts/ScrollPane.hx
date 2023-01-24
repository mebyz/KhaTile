package koui.elements.layouts;

import koui.events.MouseEvent.MouseHoverEvent;
import koui.events.MouseEvent.MouseClickEvent;
import koui.events.MouseEvent.MouseScrollEvent;
import kha.Image;

import koui.events.EventHandler;
import koui.graphics.KGraphics;
import koui.utils.MathUtil;
import koui.theme.ThemeUtil;

/**
	A scroll pane works like an `AnchorPane` with scroll bars if the content
	grows larger than the scroll pane element.

	![ScrollPane screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_scrollpane.png)

	Note that scroll panes only use `TopLeft` anchors for their child elements,
	every other anchor will be ignored.

	@see `Config.scrollSensitivity`
**/
class ScrollPane extends Layout {
	var elements: Array<Element> = new Array();
	var scrollX: kha.FastFloat = 0.0;
	var scrollY: kha.FastFloat = 0.0;

	var contentHeight = 0.0;
	var contentWidth = 0.0;

	var scrollTexture: Image;
	var sG: KGraphics;

	var scrollbarWidth = 16;
	// -1 = no scrollbar
	var scrollbarLengthRight = -1;
	var scrollbarLengthBottom = -1;
	var isHovered = false;
	// Which scrollbar is currently clicked
	var clicked: Scrollbar = None;
	// Positions relative to the scrollbar that the user clicked
	var clickOffsetRight = 0;
	var clickOffsetBottom = 0;

	public function new(posX: Int, posY: Int, width: Int, height: Int) {
		super(posX, posY, width, height);

		createNewScrollTexture();

		#if !KOUI_EVENTS_OFF
		addEventListener(MouseScrollEvent, _onScroll);
		addEventListener(MouseClickEvent, _onClick);
		addEventListener(MouseHoverEvent, _onHover);
		#end
	}

	override function initStyle() {
		requireStates(["hover", "click"], "bar_thumb");
		requireStates(["hover", "click"], "bar_track");
		requireContextElement("corner");
	}

	inline function createNewScrollTexture() {
		scrollTexture = Image.createRenderTarget(Std.int(width), Std.int(height), null, NoDepthAndStencil, 1);
		sG = new KGraphics(scrollTexture);
	}

	override function onTIDChange() {
		ThemeUtil.requireOptGroups(["scrollbar"]);

		this.scrollbarWidth = style.scrollbar.width;
	}

	/**
	 * Adds an element to the scroll pane.
	 * @param element The element
	 */
	public function add(element: Element) {
		element.layout = this;
		elements.push(element);
	}

	function recalculateScrollbarLengths() {
		if (contentHeight > height) {
			// Ratio * height
			scrollbarLengthRight = Std.int(height / contentHeight * height);
		}
		if (contentWidth > width) {
			scrollbarLengthBottom = Std.int(width / contentWidth * width);
		}
	}

	function recalcElement(element: Element) {
		// ScrollPane does not support anchors (better: it always uses the
		// TopLeft anchor) because it would not work to guess the position for
		// the anchor before knowing the content size of the ScrollPane
		element.layoutX = element.posX + paddingLeft;
		element.layoutY = element.posY + paddingTop;

		// Only scale to the right and down, otherwise we would have to
		// calculate an offset for the elements in this pane.
		// Also, do not take padding[Top/Left] into account here because they're
		// already calculated in layout[X/Y]
		if (element.layoutX + element.layoutWidth + paddingRight > contentWidth) {
			contentWidth = element.layoutX + element.layoutWidth + paddingRight;
		}
		if (element.layoutY + element.layoutHeight + paddingBottom > contentHeight) {
			contentHeight = element.layoutY + element.layoutHeight + paddingBottom;
		}

		// Ensure that the child elements of the element are also repositioned
		// if the element is a layout
		Layout.resizeIfLayout(element);
	}

	public function remove(element: Element) {
		elements.remove(element);
		element.layout = null;
	}

	public override function resize(width: Int, height: Int) {
		super.resize(width, height);

		createNewScrollTexture();
		for (element in elements) {
			if (needsValidation(element)) {
				recalcElement(element);
			}
		}
		recalculateScrollbarLengths();
	}

	public override function elemUpdated(element: Element) {
		recalcElement(element);
	}

	override function getAllElements(): Iterable<Element> {
		return elements;
	}

	#if !KOUI_EVENTS_OFF
	function _onScroll(event: MouseScrollEvent) {
		// Make mouse position relative
		var mouseY = EventHandler.mouseY + getLayoutOffset()[1];

		// Hovered over the bottom scroll bar
		if (scrollbarLengthBottom != -1 && mouseY > drawY + drawHeight - scrollbarWidth) {
			scrollX += event.scrollDelta * Config.scrollSensitivity;
			scrollX = MathUtil.clamp(scrollX, 0, contentWidth - width);
		} else {
			scrollY += event.scrollDelta * Config.scrollSensitivity;
			scrollY = MathUtil.clamp(scrollY, 0, contentHeight - height);
		}
	}

	function _onHover(event: MouseHoverEvent) {
		switch (event.getState()) {
			case HoverStart, HoverActive:
				isHovered = true;
			case HoverEnd:
				isHovered = false;
		}
	}

	function _onClick(event: MouseClickEvent) {
		switch (event.getState()) {
			case ClickStart:
				// Make mouse position relative
				var layoutOffset = getLayoutOffset();
				var mouseX = EventHandler.mouseX + layoutOffset[0];
				var mouseY = EventHandler.mouseY + layoutOffset[1];

				if (scrollbarLengthRight != -1 && mouseX >= drawX + width
						&& mouseY < drawY + height) {
					clicked = Right;

					var scrollOffset = scrollY / contentHeight * height;
					clickOffsetRight = Std.int(mouseY - posY - scrollOffset);
				}

				if (scrollbarLengthBottom != -1 && mouseY >= drawY + height
						&& mouseX < drawX + width) {
					clicked = Bottom;

					var scrollOffset = scrollX / contentWidth * width;
					clickOffsetBottom = Std.int(mouseX - posX - scrollOffset);
				}

				EventHandler.block(this);

			case ClickHold:
				// Make mouse position relative
				var layoutOffset = getLayoutOffset();
				var mouseX = EventHandler.mouseX + layoutOffset[0];
				var mouseY = EventHandler.mouseY + layoutOffset[1];

				if (clicked == Right) {
					scrollY = MathUtil.mapToRange(
						mouseY - clickOffsetRight,
						posY, posY + height - scrollbarLengthRight,
						0, contentHeight - height);
					scrollY = MathUtil.clamp(scrollY, 0, contentHeight - height);
				}

				if (clicked == Bottom) {
					scrollX = MathUtil.mapToRange(
						mouseX - clickOffsetBottom,
						posX, posX + width - scrollbarLengthBottom,
						0, contentWidth - width);
					scrollX = MathUtil.clamp(scrollX, 0, contentWidth - width);
				}

			case ClickEnd, ClickCancelled:
				clicked = None;
				EventHandler.unblock();
		}
	}
	#end

	override function draw(g: KGraphics) {
		g.end();

		resetContext();
		sG.begin(true, style.color.bg);

		sG.pushTranslation(-scrollX, -scrollY);

		// Overlays are not drawn in the scroll pane to prevent clipping
		for (element in elements) {
			renderElement(sG, element);
		}

		sG.popTransformation();
		sG.end();

		g.begin(false);
		g.pushTranslation(drawX, drawY);

		g.color = 0xffffffff;
		g.opacity = 1;
		g.drawImage(scrollTexture, 0, 0);

		drawScrollbars(g);

		#if KOUI_DEBUG_LAYOUT
		g.color = Config.DBG_COLOR_SCROLLPANE;
		g.font = Koui.font;
		g.fontSize = 16;
		g.drawLine(0, 0, width, 0);
		g.drawLine(0, height, width, height);
		g.drawLine(0, 0, 0, height);
		g.drawLine(width, 0, width, height);
		g.drawString('w: $width, h: $height', 0, 0);
		#end

		g.popTransformation();
	}

	/**
	 * Draws the scrollbars of this pane. Currently, the scrollbars are only
	 * drawn outside of the pane.
	 * @param g The `kha.graphics2.Graphics` object for drawing
	 */
	function drawScrollbars(g: KGraphics) {
		if (scrollbarLengthRight != -1) {
			drawWidth = width + scrollbarWidth;
			var scrollRatio = scrollY / contentHeight;

			setContextElement("bar_track");
			if (clicked == Right) setContextState("click");
			else if (isHovered) setContextState("hover");

			g.opacity = style.opacity;
			g.fillKRect(width, 0, scrollbarWidth, height, style);

			setContextElement("bar_thumb");
			g.opacity = style.opacity;
			g.fillKRect(width, scrollRatio * height, scrollbarWidth, scrollbarLengthRight, style);
		}

		if (scrollbarLengthBottom != -1) {
			drawHeight = height + scrollbarWidth;
			var scrollRatio = scrollX / contentWidth;

			setContextElement("bar_track");
			if (clicked == Bottom) setContextState("click");
			else if (isHovered) setContextState("hover");

			g.opacity = style.opacity;
			g.fillKRect(0, height, width, scrollbarWidth, style);

			setContextElement("bar_thumb");
			g.opacity = style.opacity;
			g.fillKRect(scrollRatio * width, height, scrollbarLengthBottom, scrollbarWidth, style);
		}

		if (scrollbarLengthRight != -1 && scrollbarLengthBottom != -1) {
			setContext("default", "corner");
			g.opacity = style.opacity;
			g.fillKRect(width, height, scrollbarWidth, scrollbarWidth, style);
		}
	}

	/**
	 * Returns the topmost element at the given position. If no element exists
	 * at that position, `null` is returned.
	 *
	 * @param x The position's x coordinate
	 * @param y The position's y coordinate
	 * @return The element at the given position, `this` if not found but the
	 *         the mouse is over the scrollpane or `null` if the mouse is not
	 *         over the scrollpane.
	 */
	public override function getElementAtPosition(x: Int, y: Int): Null<Element> {
		// If the mouse is not over this scrollpane, don't check the contained
		// elements and return `null`.
		if (!MathUtil.hitbox(x, y, drawX, drawY, width, height)) {
			// Check scrollbars
			if (scrollbarLengthRight != -1) {
				if (MathUtil.hitbox(x, y, drawX + width, drawY, scrollbarWidth, height)) {
					return this;
				}
			}

			if (scrollbarLengthBottom != -1) {
				if (MathUtil.hitbox(x, y, drawX, drawY + height, width, scrollbarWidth)) {
					return this;
				}
			}

			return null;
		}

		if (absorbEvents) return this;

		// Make coords relative to this layout
		x = Std.int(x - drawX + scrollX);
		y = Std.int(y - drawY + scrollY);

		// Reverse to ensure that the topmost element is selected
		var sorted_elements = elements.copy();
		sorted_elements.reverse();

		for (element in sorted_elements) {
			if (!element.visible) {
				continue;
			}
			var hit = element.getElementAtPosition(x, y);
			if (hit != null) return hit;

			if (element.isAtPosition(x, y)) return element;
		}

		return this;
	}
}

private enum abstract Scrollbar(Int) {
	var None = 0;
	var Right = 1;
	var Bottom = 2;
}
