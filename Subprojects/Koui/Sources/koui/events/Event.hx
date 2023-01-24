package koui.events;

import haxe.rtti.Meta;

import koui.elements.Element;

/**
	An event represents an action or state change on which the application can
	react. Each event has a state which further characterizes the event and
	– depending on its type – it can hold further information about the action.

	@see [Wiki: Events](https://gitlab.com/koui/Koui/-/wikis/Documentation/Events)
**/
@:autoBuild(koui.events.EventMacro.buildEventSubClass())
@typeUID("event")
abstract class Event {
	/**
		The element that receives this event. If null, this event is not
		dispatched.
	**/
	public final element: Null<Element>;

	final state: Int;

	/**
		Creates a new event for the given element with the given state. This
		method does not dispatch (send) the event, that happens in
		`Event.dispatch()`.

		@see `Event.dispatch()`
	**/
	public function new(element: Null<Element>, state: Int) {
		this.element = element;
		this.state = state;
	}

	// TODO: Investigate if this can work with generics (covariance...) and
	// whether it can then be inlined or if the state variable can just be public
	public function getState(): Int {
		return 0;
	}

	/**
		Return a string representation of the event type.

		Event subclasses set this property via the `@typeUID("event")` runtime
		metadata, which expects the type's identifier as a `String` parameter.
		If you create your own event types, make sure that this metadata exists
		(also at runtime, don't use `@:`) and to give the event class a *unique*
		name!
	**/
	public static inline function getTypeUID(eventClass: Class<Event>): String {
		// TODO: Get rid of metadata eventually
		return Meta.getType(eventClass).typeUID[0];
	}

	/**
		Calls all event listeners that listen for this event.

		@see `Element.addEventListener()`
	**/
	public static function dispatch<T: Event>(event: T) {
		var toElement = event.element;
		if (toElement == null) {
			return;
		}

		var typeUID = getTypeUID(cast Type.getClass(event));

		var listeners = @:privateAccess toElement.eventListeners[typeUID];
		if (listeners == null) return;

		for (listener in listeners) {
			@:privateAccess listener.callback(event);
		}
	}
}

/**
	Represents a bit flag. The `index` states which position should be a 1.
**/
@:keep
@:dox(show)
inline function flag(index: Int): Int {
	return 1 << index;
}
