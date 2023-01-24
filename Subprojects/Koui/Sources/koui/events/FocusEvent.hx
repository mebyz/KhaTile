package koui.events;

import koui.elements.Element;
import koui.events.Event.flag;
import koui.events.MouseEvent.MouseButton;
import koui.events.MouseEvent.MouseButtonEvent;

/**
	A `Focus` event is fired when the mouse clicks on a element that was not
	focused before. The previously focused element (might be `null` as well)
	is no longer focused then.
**/
class FocusEvent extends MouseButtonEvent {
	public function new(element: Null<Element>, state: FocusEventState, mouseButton: MouseButton) {
		super(element, state, mouseButton);
	}

	override public function getState(): FocusEventState {
		return this.state;
	}
}

enum abstract FocusEventState(Int) from Int to Int {
	/**
		Fired once when the element is focused.
	**/
	var FocusGet = flag(0);

	/**
		Fired once when the element is no longer focused. Also fired when
		`EventHandler.clearFocus()` is called.
	**/
	var FocusLoose = flag(1);
}
