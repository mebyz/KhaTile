package koui.events;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;

class EventMacro {
	static macro function buildEventSubClass(): Array<Field> {
		var localClass = Context.getLocalClass().get();
		var fields = Context.getBuildFields();

		var typeUID = "localClass.module" + "." + localClass.name;

		localClass.meta.add("typeUID", [macro $v{typeUID}], Context.currentPos());

		return fields;
	}
}
