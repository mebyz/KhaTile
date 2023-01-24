package koui.utils;

@:generic
class Set<T: Dynamic> {
	var map: Map<T, Bool>;

	public inline function new() {
		map = new Map<T, Bool>();
	}

	public inline function add(val: T): Void {
		map.set(val, true);
	}

	public inline function remove(val: T): Void {
		map.remove(val);
	}

	public inline function has(val: T): Bool {
		return map.exists(val);
	}

	public inline function clear(): Void {
		map.clear();
	}

	public function toArray(): Array<T> {
		var out = new Array<T>();

		for (key in map.keys()) {
			out.push(key);
		}

		return out;
	}

	public inline function iterator(): Iterator<T> {
		return map.keys();
	}
}
