package koui.utils;

import koui.elements.RadioButton;
import koui.events.Event;
import koui.events.CheckboxEvent;


@:access(koui.elements.RadioButton)
class RadioGroup {
	public var activeButton(default, null): Null<RadioButton>;

	var buttons: Array<RadioButton> = new Array();
	var onButtonChangedFunc: RadioButton->Void = (button: RadioButton) -> {};

	public function new() {}

	public function add(button: RadioButton) {
		buttons.push(button);

		if (buttons.length == 1) setActiveButton(button);
	}

	public function setActiveButton(button: RadioButton) {
		if (activeButton != null) {
			activeButton.onUncheckedFunc();
			Event.dispatch(new CheckboxEvent(activeButton, Unchecked));
		}
		activeButton = button;

		for (bt in buttons) {
			bt.isChecked = false;
		}

		button.isChecked = true;
		button.onCheckedFunc();
		Event.dispatch(new CheckboxEvent(activeButton, Checked));
		onButtonChangedFunc(button);
	}

	/**
	 * Run the given callback after `setActiveButton()` was called.
	 */
	public inline function onButtonChanged(callback: RadioButton->Void) {
		onButtonChangedFunc = callback;
	}
}
