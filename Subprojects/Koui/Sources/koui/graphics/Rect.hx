package koui.graphics;

import kha.FastFloat;

/**
 * A simple rectangle shape.
 */
class Rect {
	public var left: FastFloat;
	public var top: FastFloat;
	public var width: FastFloat;
	public var height: FastFloat;

	public var right(get, set): FastFloat;
	function get_right(): FastFloat {
		return left + width;
	}
	function set_right(value: FastFloat): FastFloat {
		width = value - left;
		return value;
	}

	public var bottom(get, set): FastFloat;
	function get_bottom(): FastFloat {
		return top + height;
	}
	function set_bottom(value: FastFloat): FastFloat {
		height = value - top;
		return value;
	}

	public function new(left: Float, top: Float, width: Float, height: Float) {
		this.left = left;
		this.top = top;
		this.width = width;
		this.height = height;
	}
}
