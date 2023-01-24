package koui.events;

import koui.elements.Element;
import koui.events.Event;

class KeyEvent extends Event {}

class KeyCodeEvent extends KeyEvent {
	/**
		The key code that corresponds to the key that triggered the event.
	**/
	public final keyCode: kha.input.KeyCode;

	public function new(element: Null<Element>, state: Int, keyCode: kha.input.KeyCode) {
		super(element, state);

		this.keyCode = keyCode;
	}
}

/**
	A `KeyCodeStatus` event is fired on the first frame a key was pressed down
	or was released, so everytime the key's **status** was changed.
**/
class KeyCodeStatusEvent extends KeyCodeEvent {
	public function new(element: Null<Element>, state: KeyCodeStatusEventState, keyCode: kha.input.KeyCode) {
		super(element, state, keyCode);
	}

	override public function getState(): KeyCodeStatusEventState {
		return this.state;
	}
}

enum abstract KeyCodeStatusEventState(Int) from Int to Int {
	/**
		Fired on the first frame a key is pressed down.
	**/
	var KeyDown = flag(0);

	/**
		Fired on the first frame after a key was released.
	**/
	var KeyUp = flag(1);
}

/**
	A `KeyCodePress` event is fired on the first frame a key is pressed and
	after that on a certain time interval to simulate a OS-like input behaviour.
	That interval can be controlled by `EventHandler.KEY_REPEAT_DELAY` and
	`EventHandler.KEY_REPEAT_PERIOD`.

	@see `KeyCharPressEvent`
**/
class KeyCodePressEvent extends KeyCodeEvent {
	public function new(element: Null<Element>, state: KeyCodePressEventState, keyCode: kha.input.KeyCode) {
		super(element, state, keyCode);
	}

	override public function getState(): KeyCodePressEventState {
		return this.state;
	}
}

enum abstract KeyCodePressEventState(Int) from Int to Int {
	/**
		Fired on the first frame a key is pressed down.
	**/
	var KeyDown = flag(0);

	/**
		Fired on all consecutive time steps of the key press interval.
	**/
	var KeyHold = flag(1);
}

/**
	A `KeyCharPress` event is fired on the first frame a key is pressed and
	after that on a certain time interval to simulate a OS-like input behaviour.
	That interval can be controlled by `EventHandler.KEY_REPEAT_DELAY` and
	`EventHandler.KEY_REPEAT_PERIOD`.

	Please note that this event is only fired by keys that represent a character
	due to internal limitations. For an event that also handles other keys,
	please refer to `KeyCodePressEvent`.

	@see `KeyCodePressEvent`
**/
class KeyCharPressEvent extends KeyEvent {
	/**
		The character of the key that triggered the event.
	**/
	public final keyChar: String;

	public function new(element: Null<Element>, state: KeyCharPressEventState, keyChar: String) {
		super(element, state);

		this.keyChar = keyChar;
	}

	override public function getState(): KeyCharPressEventState {
		return this.state;
	}
}

enum abstract KeyCharPressEventState(Int) from Int to Int {
	/**
		Fired on the first frame a key is pressed down and on all consecutive
		time steps of the key press interval.
	**/
	var KeyHold = flag(0);
}
