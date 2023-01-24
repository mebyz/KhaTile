package koui.elements;

import haxe.ds.Vector;

import koui.graphics.KGraphics;
import koui.elements.layouts.Layout;
import koui.elements.layouts.ScrollPane;
import koui.events.EventHandler;
import koui.events.EventListener;
import koui.theme.Style;
import koui.utils.ElementMatchBehaviour;
import koui.utils.MathUtil;
import koui.utils.Set;

/**
 * The base class of all elements.
 */
@:allow(koui.Koui)
@:allow(koui.events.EventHandler)
@:autoBuild(koui.theme.ThemeUtil.buildSubElement())
class Element {
	/**
	 * Set of elements for which to notify their parent layout about a change of
	 * position or size on the next frame.
	 */
	static var invalidations: Set<Element> = new Set();

	/** The x position of this element. */
	public var posX(default, set): Int = 0;
	/** The y position of this element. */
	public var posY(default, set): Int = 0;
	/** The width of this element. */
	public var width(default, set): Int = 0;
	/** The height of this element. */
	public var height(default, set): Int = 0;

	/**
	 * The anchor of this element. Used for the layout.
	 * @see `Anchor`
	 */
	public var anchor = Anchor.FollowLayout;

	/**
	 * `true` if the element is disabled and should not react to events. Also,
	 * elements might look different if disabled depending on the theme.
	 */
	public var disabled = false;

	/**
	 * If `false`, the element is not visible and will not react to any events.
	 */
	public var visible = true;

	/**
		The layout this element belongs to.
	**/
	public var layout(default, set): Null<Layout> = null;
	private inline function set_layout(value: Null<Layout>): Layout {
		this.parent = value;
		return this.layout = value;
	}

	/**
		The parent element of this element.
	**/
	public var parent(default, null): Null<Element> = null;

	/**
		The children of this element.
	**/
	var children: Array<Element> = [];

	/**
		Whether the children of the element are automatically drawn after the
		element, or whether element must render its children by its own. The
		latter can be useful if the children need to be drawn in a specified
		order.
	**/
	var autoRenderChildren = true;

	/**
	 * The theme ID of this object. Use this to select which theme settings to
	 * apply.
	 */
	var tID(default, set) = "_root";

	/** ctxElement!state => style */
	var stylesCache(default, null): Map<String, Style>;
	/** Style of the current context */
	var style(default, null): Style;
	/** States for each context element: ctxElement => states */
	var states(default, null) = ["" => ["default", "disabled"]];
	/** Current context state */
	var state(default, null) = "default";
	/** Current context element */
	var ctxElement(default, null) = "";

	/** Whether this element already initialized its style. **/
	var styleInitialized = false;

	/** The x position of this element, used for drawing and event handling. */
	var drawX(default, null): Int;
	/** The y position of this element, used for drawing and event handling. */
	var drawY(default, null): Int;
	/** The width of this element, used for drawing and event handling. */
	var drawWidth(default, null): Int;
	/** The height of this element, used for drawing and event handling. */
	var drawHeight(default, null): Int;
	/** The x position of this element, used for the layout. */
	var layoutX(default, set): Int;
	/** The y position of this element, used for the layout. */
	var layoutY(default, set): Int;
	/** The width of this element, used for the layout. */
	var layoutWidth(default, set): Int;
	/** The height of this element, used for the layout. */
	var layoutHeight(default, set): Int;

	var eventListeners: Map<String, Array<EventListener<Event>>> = new Map();

	/**
	 * Create a new `Element`.
	 */
	function new(?__isSuperCall = false) {
		onBuild();

		initStyle();
		onTIDChange();

		EventHandler.registerElement(this);
	}

	function onBuild() {}

	function initStyle() {}

	public inline function addChild(child: Element) {
		child.parent = this;
		this.children.push(child);
	}

	public inline function removeChild(child: Element) {
		child.parent = null;
		this.children.remove(child);
	}

	public function getChild<T:Element>(matchBehaviour: ElementMatchBehaviour): Null<T> {
		for (child in children) {
			if (matchBehaviour.match(child)) {
				return cast child;
			}
		}
		return null;
	}

	/**
	 * Return a string representation of this element:
	 * `"Element: <[ClassName]>"`
	 */
	public function toString(): String {
		return 'Element: <${Type.getClassName(Type.getClass(this))}>';
	}

	/**
	 * Setup the given element for drawing and call its draw method afterwards.
	 */
	public final inline function renderElement(g: KGraphics, element: Element) {
		if (!element.visible) return;
		g.opacity = element.style.opacity;

		element.draw(g);

		if (element.autoRenderChildren) {
			renderChildren(g, element);
		}
	}

	inline function renderChildren(g: KGraphics, element: Element) {
		g.pushTranslation(element.drawX, element.drawY);
		for (c in element.children) {
			renderElement(g, c);
		}
		g.popTransformation();
	}

	function draw(g: KGraphics) {
		Log.error("draw() function must be overriden by element!");
	}

	function drawOverlay(g: KGraphics) {}

// =============================================================================
// POSITION & SIZE
// =============================================================================

	/**
	 * Set the position of this element. You can also change the position
	 * per axis, see [`posX`](#posX) and [`posY`](#posY).
	 */
	public inline function setPosition(posX: Int, posY: Int) {
		this.posX = posX;
		this.posY = posY;
	}

	/**
	 * Set the size of this element. You can also change the size for each
	 * individual side, see [`width`](#width) and [`height`](#height).
	 */
	public inline function setSize(width: Int, height: Int) {
		this.width = width;
		this.height = height;
	}

	/**
	 * Return the offset of the element's position to the screen.
	 */
	public function getLayoutOffset(): Vector<Int> {
		var offset = new Vector<Int>(2);
		offset[0] = 0;
		offset[1] = 0;

		// Start with `this` to be less redundant with the following code
		var currentParent: Element = this;
		while (currentParent.layout != null) {
			currentParent = currentParent.layout;

			if (Std.isOfType(currentParent, Layout)) {
				offset[0] -= currentParent.layoutX;
				offset[1] -= currentParent.layoutY;

				if (Std.isOfType(currentParent, ScrollPane)) {
					var sp = cast(currentParent, ScrollPane);
					offset[0] += Std.int(@:privateAccess sp.scrollX);
					offset[1] += Std.int(@:privateAccess sp.scrollY);
				}
			}
		}

		return offset;
	}

	/**
	 * Return `true` if this element overlaps with the given position. Used
	 * internally for event handling most of the time. Elements may override
	 * this method to provide more detailed mouse interaction.
	 * If the element is invisible, `false` is returned.
	 */
	public inline function isAtPosition(x: Int, y: Int) {
		if (!visible) return false;
		// Use drawing measures to take overlays into account
		return MathUtil.hitbox(x, y, this.drawX, this.drawY, this.drawWidth, this.drawHeight);
	}

	inline function getAnchorResolved(): Anchor {
		if (this.anchor == FollowLayout && this.layout != null) return this.layout.defaultAnchor;
		return this.anchor;
	}

	/**
	 * Notify the parent layout on the next frame that this element has changed
	 * its size or position. Use the next frame to make sure we don't waste
	 * calculations when more than one value changes during one frame.
	 */
	inline function invalidateElem() {
		Element.invalidations.add(this);
	}

	// Change to publishEvent(Resize) API? Then the user could also listen to this
	function onResize() {}

	function set_posX(value: Int) { if (value != posX) { invalidateElem(); } return posX = layoutX = value; }
	function set_posY(value: Int) { if (value != posY) { invalidateElem(); } return posY = layoutY = value; }
	function set_width(value: Int) {
		var changed = value != width;
		if (changed) {
			invalidateElem();
		}
		width = layoutWidth = value;
		if (changed) {
			onResize();
		}
		return width;
	}
	function set_height(value: Int) {
		var changed = value != height;
		if (changed) {
			invalidateElem();
		}
		height = layoutHeight = value;
		if (changed) {
			onResize();
		}
		return height;
	}
	function set_layoutX(value: Int) { return layoutX = drawX = value; }
	function set_layoutY(value: Int) { return layoutY = drawY = value; }
	function set_layoutWidth(value: Int) { return layoutWidth = drawWidth = value; }
	function set_layoutHeight(value: Int) { return layoutHeight = drawHeight = value; }

// =============================================================================
// STYLE & DRAWING CONTEXT
// =============================================================================

	/**
	 * `tID` setter. Caches all styles required by this element.
	 */
	function set_tID(value: String): String {
		this.tID = value;

		this.stylesCache = new Map();

		for (ctxElementName => ctxElementStates in this.states) {
			cacheStates(ctxElementStates, ctxElementName);
		}

		loadStyle();

		return tID;
	}

	@:dox(hide)
	inline function initTID(tID: String, constrCalled: String) {
		if (!styleInitialized) {
			this.tID = tID;
			styleInitialized = true;
		}
	}

	/**
	 * Set the theme ID of this element.
	 */
	public function setTID(tID: String) {
		if (this.tID != tID) {
			this.tID = tID;
			setContextElement("");
			onTIDChange();
		}
	}
	public inline function getTID(): String { return this.tID; }

	inline function requireStates(states: Array<String>, ctxElement: String = "") {
		requireContextElement(ctxElement);
		this.states[ctxElement] = this.states[ctxElement].concat(states);
		// TODO: requireContext already caches some states, don't do double work here
		cacheStates(this.states[ctxElement], ctxElement);
	}

	function cacheStates(states: Array<String>, ctxElement: String = "") {
		// Get selector name from context element/suffix
		var selectorBaseName = (ctxElement == "") ? tID : tID + "_" + ctxElement;

		for (s in states) {
			// Use the context element name as the key to re-use cache entries
			// when changing tID (key is tID-independent)
			var key = ctxElement + "!" + s;

			stylesCache[key] = Style.getStyle(selectorBaseName, s);
			if (stylesCache[key] == null) {
				Log.warn('Missing selector in theme file: "${selectorBaseName + "!" + s}", trying to use default state instead.');

				// Use default state instead
				stylesCache[key] = Style.getStyle(selectorBaseName, "default");
				if (stylesCache[key] == null) {
					Log.error('Missing selector in theme file: "${selectorBaseName + "!" + s}"!');
				}
			}
		}
	}

	inline function requireContextElement(ctxElement: String) {
		if (!this.states.exists(ctxElement)) {
			// Create default entry to ensure we can concatenate in requireStates()
			this.states[ctxElement] = ["default", "disabled"];
			cacheStates(this.states[ctxElement], ctxElement);
		}
	}

	/**
	 * Set the current style context used for drawing. Calling this function is
	 * equivalent to calling `setContextState` and `setContextElement`. If the
	 * given element name is `""`, the element's `tID` is used.
	 *
	 * @param state
	 * @param ctxElement
	 *
	 * @see `setContextElement`
	 * @see `setContextState`
	 * @see `resetContext`
	 */
	inline function setContext(state: String, ctxElement: String = "", recursive: Bool = true) {
		this.state = state;
		this.ctxElement = ctxElement;
		loadStyle();

		if (recursive) {
			for (c in children) {
				c.setContext(state, ctxElement, true);
			}
		}
	}

	/**
	 * Set the drawing context element but keep the current state. If the given
	 * element name is `""`, the element's `tID` is used.
	 *
	 * @see `setContextState`
	 * @see `setContext`
	 * @see `resetContext`
	 */
	inline function setContextElement(ctxElement: String = "") {
		this.ctxElement = ctxElement;
		loadStyle();
	}

	/**
	 * Set the drawing context state but keep the current element.
	 *
	 * @see `setContextElement`
	 * @see `setContext`
	 * @see `resetContext`
	 */
	inline function setContextState(state: String, recursive: Bool = true) {
		this.state = state;
		loadStyle();

		if (recursive) {
			for (c in children) {
				c.setContextState(state, true);
			}
		}
	}

	inline function getContextState(): String {
		return this.state;
	}

	/**
		Sets the style variable to point to the current context.
	**/
	function loadStyle() {
		var stateStyle = stylesCache[ctxElement + "!" + state];

		if (stateStyle != null) {
			this.style = stateStyle;
		}
		else {
			if (ctxElement == "") ctxElement = tID;
			else ctxElement = tID + "_" + ctxElement;
			Log.error('$this, $tID: No cached style found for tID "$ctxElement" and state "$state"!');
		}
	}

	inline function resetContext() {
		this.setContext(this.disabled ? "disabled" : "default", "");
	}

	inline function resetContextState() {
		this.setContextState(this.disabled ? "disabled" : "default");
	}

	/**
		Called when the theme ID changed.
	**/
	function onTIDChange() {}

// =============================================================================
// EVENTS
// =============================================================================

	/**
		Register a callback to be called if the given event occurs on this
		element.

		**Example**:
		```haxe
		var button = new Button("Hello!");
		button.addEventListener(MouseClickEvent, (event: MouseClickEvent) -> {
			if (event.mouseButton == Left && event.getState() == ClickStart) {
				trace("Clicked!");
			}
		});
		```

		@param eventClass The class of the event, must be a subclass of `koui.events.Event`
		@param callback The callback function to call if the event occurs
	**/
	public final function addEventListener<T: Event>(eventClass: Class<T>, callback: T->Void) {
		var typeUID: String = Event.getTypeUID(cast eventClass);
		if (eventListeners[typeUID] == null) {
			eventListeners.set(typeUID, new Array<EventListener<Event>>());
		}

		eventListeners[typeUID].push(cast new EventListener<T>(callback));
	}

	/**
		Returns whether this element has a registered event listener for the
		given event type.
	**/
	public final inline function listensTo<T: Event>(eventClass: Class<T>): Bool {
		return eventListeners.exists(Event.getTypeUID(cast eventClass));
	}

	/**
		Returns whether this element has a registered event listener for the
		given event type.
	**/
	public final inline function listensToUID<T: Event>(eventTypeUID: String): Bool {
		return eventListeners.exists(eventTypeUID);
	}

	public function getElementAtPosition(x: Int, y: Int): Null<Element> {
		// If the mouse does not hover over this AnchorPane, don't check the
		// contained elements and return `null`.
		if (!this.isAtPosition(x, y)) return null;

		if (children.length == 0) return this;

		// Make coords relative to this element
		x = x - layoutX;
		y = y - layoutY;

		// Reverse to ensure that the topmost element is selected
		// TODO: Add custom iterator for iterating in reverse (no need to copy data)
		var sortedElements = children.copy();
		sortedElements.reverse();

		for (element in sortedElements) {
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
