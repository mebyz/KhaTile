package koui.events;

import koui.elements.Element;
import koui.events.Event;

class ValueChangeEvent extends Event {
	public function new(element: Null<Element>) {
		super(element, 0);
	}
}
