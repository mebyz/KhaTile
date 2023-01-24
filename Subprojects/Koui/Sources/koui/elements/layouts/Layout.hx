package koui.elements.layouts;

import koui.events.Event;
import koui.utils.Log;

/**
 * Base class for all layouts.
 */
class Layout extends Element {
	public var paddingLeft(default, set) = 0;
	public var paddingRight(default, set) = 0;
	public var paddingTop(default, set) = 0;
	public var paddingBottom(default, set) = 0;

	public var defaultAnchor: Anchor = TopLeft;

	/**
	 * `true` if the layout needs to be recalculated before the next frame.
	 */
	public var invalidLayout(default, null) = false;

	/**
	 * If `true`, all invalid layouts (and only those) are currently validated.
	 */
	static var isValidating: Bool = false;

	/**
	 * If `true`, this Layout does receive events and block sub-elements from
	 * receiving them.
	 *
	 * @see `Layout.spreadEvents`
	 */
	public var absorbEvents = false;

	/**
	 * If `true`, **all** elements of this layout will receive the same events
	 * as the layout itself. Individual events are not received then.
	 *
	 * This behaviour takes effect only if `Layout.absorbEvents` is `true`.
	 */
	public var spreadEvents = false;

	function new(posX: Int, posY: Int, width: Int, height: Int) {
		super();

		setPosition(posX, posY);
		setSize(width, height);
	}

	public override function onTIDChange() {
		this.paddingLeft = style.padding.left;
		this.paddingRight = style.padding.right;
		this.paddingTop = style.padding.top;
		this.paddingBottom = style.padding.bottom;
	}

	public function resize(width: Int, height: Int) {
		this.layoutWidth = width;
		this.layoutHeight = height;

		if (Layout.isValidating) {
			this.invalidLayout = false;
		}
	}

	/**
	 * Resizes the given element if it is a layout.
	 */
	public static function resizeIfLayout(element: Element) {
		if (Std.isOfType(element, Layout)) {
			var lyt = cast(element, Layout);
			lyt.resize(element.layoutWidth, element.layoutHeight);
		}
	}

	/**
	 * Mark this layout as invalid so that it is recalculated before the next
	 * frame is drawn.
	 */
	public function invalidateLayout() {
		this.invalidLayout = true;

		// Mark all parent layouts as invalid
		var parent = this;
		while (parent.layout != null) {
			parent = parent.layout;
			parent.invalidLayout = true;
		}
	}

	function needsValidation(element: Element): Bool {
		if (isValidating && Std.isOfType(element, Expander)) {
			if (!cast(element, Expander).invalidLayout) {
				return false;
			}
		}
		return true;
	}

	override function draw(g: koui.graphics.KGraphics) {
		Log.error("draw() function must be overriden by layout!");
	}


	/**
	 * Calculates the size of the given element if the size is defined as
	 * dynamic by the element's style, taking the dimension of the parent
	 * container and the anchor point into account (the container might be a
	 * layout or a subsection for example).
	 *
	 * @return Bool Whether the element was resized
	 */
	public function calcElementSize(element: Element, parentWidth: Int, parentHeight: Int): Bool {
		var minWidth = element.style.size.minWidth;
		var maxWidth = element.style.size.maxWidth;
		var minHeight = element.style.size.minHeight;
		var maxHeight = element.style.size.maxHeight;

		var resized = false;

		// Do dynamic scaling if [min/max]Width are > 0
		if (minWidth > 0 || maxWidth > 0) {
			element.layoutWidth = parentWidth - paddingLeft - paddingRight;

			switch (element.getAnchorResolved()) {
				case TopLeft, TopCenter, MiddleLeft, MiddleCenter, BottomLeft, BottomCenter:
					element.layoutWidth -= Std.int(Math.abs(element.posX));
				case TopRight, MiddleRight, BottomRight:
					element.layoutWidth += Std.int(Math.abs(element.posX));
				default:
			}

			if (minWidth > 0 && element.layoutWidth < minWidth) element.layoutWidth = minWidth;
			if (maxWidth > 0 && element.layoutWidth > maxWidth) element.layoutWidth = maxWidth;

			resized = true;
		}

		if (minHeight > 0 || maxHeight > 0) {
			element.layoutHeight = parentHeight - paddingTop - paddingBottom;

			switch (element.getAnchorResolved()) {
				case TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight:
					element.layoutHeight -= Std.int(Math.abs(element.posY));
				case BottomLeft, BottomCenter, BottomRight:
					element.layoutHeight += Std.int(Math.abs(element.posY));
				default:
			}

			if (minHeight > 0 && element.layoutHeight < minHeight) element.layoutHeight = minHeight;
			if (maxHeight > 0 && element.layoutHeight > maxHeight) element.layoutHeight = maxHeight;

			resized = true;
		}

		return resized;
	}

	/**
	 * Callback that layouts can override to get notified when an element
	 * changes its position or size. Useful for required recalculations. There
	 * is no default implementation.
	 */
	public function elemUpdated(element: Element) {}

	/**
	 * Sets the padding values of this layout.
	 * @param left The left padding
	 * @param right The right padding
	 * @param top The top padding
	 * @param bottom The bottom padding
	 */
	public inline function setPadding(left: Int, right: Int, top: Int, bottom: Int) {
		this.paddingLeft = left;
		this.paddingRight = right;
		this.paddingTop = top;
		this.paddingBottom = bottom;
	}

	function set_paddingLeft(left: Int) {
		invalidateLayout();
		return this.paddingLeft = left;
	}

	function set_paddingRight(right: Int) {
		invalidateLayout();
		return this.paddingRight = right;
	}

	function set_paddingTop(top: Int) {
		invalidateLayout();
		return this.paddingTop = top;
	}

	function set_paddingBottom(bottom: Int) {
		invalidateLayout();
		return this.paddingBottom = bottom;
	}


	// TODO: Replace this with spread to children. How should layouts handle this?
	// They have a children array anyways, could be redundant but ok...
	// function _onHover(event: Event) {
	// 	if (!spreadEvents) return;
	// 	for (e in getAllElements()) {
	// 		if (e != null) e._onHover(event);
	// 	}
	// }
	// function _onClick(event: Event) {
	// 	if (!spreadEvents) return;
	// 	for (e in getAllElements()) {
	// 		if (e != null) e._onClick(event);
	// 	}
	// }
	// function _onScroll(event: Event) {
	// 	if (!spreadEvents) return;
	// 	for (e in getAllElements()) {
	// 		if (e != null) e._onScroll(event);
	// 	}
	// }
	// function _onKeyCharPress(event: Event) {
	// 	if (!spreadEvents) return;
	// 	for (e in getAllElements()) {
	// 		if (e != null) e._onKeyCharPress(event);
	// 	}
	// }
	// function _onKeyCodePress(event: Event) {
	// 	if (!spreadEvents) return;
	// 	for (e in getAllElements()) {
	// 		if (e != null) e._onKeyCodePress(event);
	// 	}
	// }
	// function _onKeyCodeStatus(event: Event) {
	// 	if (!spreadEvents) return;
	// 	for (e in getAllElements()) {
	// 		if (e != null) e._onKeyCodeStatus(event);
	// 	}
	// }
	// function _onFocus(event: Event) {
	// 	if (!spreadEvents) return;
	// 	for (e in getAllElements()) {
	// 		if (e != null) e._onFocus(event);
	// 	}
	// }

	function getAllElements(): Iterable<Element> {
		Log.error("getAllElements() must be overriden by subclass of layout!");
		return null;
	}
}

enum abstract Anchor(Int) to Int {
	final TopLeft;
	final TopCenter;
	final TopRight;
	final MiddleLeft;
	final MiddleCenter;
	final MiddleRight;
	final BottomLeft;
	final BottomCenter;
	final BottomRight;

	/** Follows the default anchor setting of the layout this element is in. */
	final FollowLayout;
}
