package koui.events;

import koui.elements.Element;
import koui.events.Event;

class MouseEvent extends Event {}

class MouseButtonEvent extends MouseEvent {
	/**
		The mouse button that triggered this event.
	**/
	@:param public final mouseButton: MouseButton; // <-- @param automatisch zu konstruktor und konstruktor komplett generieren per Macro?

	public function new(element: Null<Element>, state: Int, mouseButton: MouseButton) {
		super(element, state);

		this.mouseButton = mouseButton;
	}
}

/**
	A `MouseClickEvent` is fired if any mouse button is clicked. Only hovered or
	focused elements can receive such events.
**/
class MouseClickEvent extends MouseButtonEvent {
	public function new(element: Null<Element>, state: MouseClickEventState, mouseButton: MouseButton) {
		super(element, state, mouseButton);
	}

	override public function getState(): MouseClickEventState {
		return this.state;
	}
}

enum abstract MouseClickEventState(Int) from Int to Int {
	/**
		Received by the hovered element if the mouse first clicks on it.
	**/
	var ClickStart = flag(0);

	/**
		Received by the focused element when the mouse button was released and
		the element is still hovered.
	**/
	var ClickEnd = flag(1);

	/**
		Received by the focused element if any mouse button is pressed.
	**/
	var ClickHold = flag(2);

	/**
		The same as `MouseClickEventState.ClickEnd` but fired when the focused
		element is no longer hovered, i.e. the clicking action was cancelled by the user.
	**/
	var ClickCancelled = flag(3);
}

/**
	A `MouseHoverEvent` is fired if the mouse cursor is above an element.
**/
class MouseHoverEvent extends MouseEvent {
	/**
		States whether the mouse was moved or is stationary over the element.
	**/
	public final mouseMoved: Bool;

	public function new(element: Null<Element>, state: MouseHoverEventState, mouseMoved: Bool) {
		super(element, state);

		this.mouseMoved = mouseMoved;
	}

	override public function getState(): MouseHoverEventState {
		return this.state;
	}
}

enum abstract MouseHoverEventState(Int) from Int to Int {
	/**
		Fired once when the mouse starts to hovers the element
	**/
	var HoverStart = flag(0);

	/**
		Fired when the mouse is no longer on the element that was hovered in the
		previous frame.
	**/
	var HoverEnd = flag(1);

	/**
		Fired every frame on which the mouse hovers the element.
	**/
	var HoverActive = flag(2);
}

/**
	A `MouseScrollEvent` is fired when the mouse wheel is rotated. Is it sent to
	the currently hovered element.
**/
class MouseScrollEvent extends MouseEvent {
	/**
		The amount of mouse wheel rotation. The faster the mouse is scrolled,
		the higher the value. The scroll delta is positive if the mouse wheel is
		scrolled down and negative if it is scrolled up.
	**/
	public final scrollDelta: Int;

	public function new(element: Null<Element>, state: MouseScrollEventState, scrollDelta: Int) {
		super(element, state);

		this.scrollDelta = scrollDelta;
	}

	override public function getState(): MouseScrollEventState {
		return this.state;
	}
}

enum abstract MouseScrollEventState(Int) from Int to Int {
	/**
		Fired when the mouse wheel is scrolled.
	**/
	var Scroll = flag(0);
}

/**
	Represents a mouse button.
**/
enum abstract MouseButton(Int) from Int to Int {
	var Left = 0;
	var Right = 1;
	var Middle = 2;
}
