package koui.events;

// TODO: Check if this can be replaced with the pure callback, using this class
// seems to be a needless allocation.
@:dox(hide)
class EventListener<T: Event> {
	var callback: T -> Void;

	public function new(callback: T -> Void) {
		this.callback = callback;
	}
}
