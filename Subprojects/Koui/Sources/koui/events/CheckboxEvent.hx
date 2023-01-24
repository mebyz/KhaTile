package koui.events;

import koui.elements.Element;
import koui.events.Event;

class CheckboxEvent extends Event {
	public function new(element: Null<Element>, state: CheckboxEventState) {
		super(element, state);
	}

	override public function getState(): CheckboxEventState {
		return this.state;
	}
}

enum abstract CheckboxEventState(Int) from Int to Int {
	var Checked: Int = flag(0);
	var Unchecked: Int = flag(1);
}
