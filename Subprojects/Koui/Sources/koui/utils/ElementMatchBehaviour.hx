package koui.utils;

import koui.elements.Element;

interface ElementMatchBehaviour {
	public function match(element: Element): Bool;
}

class TypeMatchBehaviour implements ElementMatchBehaviour {
	var type: Class<Element>;

	// TODO: Investigate behaviours without instanciation. Maybe use singletons?
	public function new(type: Class<Element>) {
		this.type = type;
	}

	public function match(element: Element): Bool {
		return Std.isOfType(element, type);
	}
}

class TIDMatchBehaviour implements ElementMatchBehaviour {
	var tID: String;

	public function new(tID: String) {
		this.tID = tID;
	}

	public function match(element: Element): Bool {
		return element.getTID() == tID;
	}
}
