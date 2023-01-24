package koui.utils;

import kha.FastFloat;

/**
 * Math utility class.
 */
@:pure
class MathUtil {
	/**
	 * Check whether the given point is inside the given rectangle
	 */
	public static inline function hitbox(pointX: Int, pointY: Int, posX: FastFloat, posY: FastFloat, sizeX: FastFloat, sizeY: FastFloat) {
		return pointX >= posX && pointX <= posX + sizeX && pointY >= posY && pointY <= posY + sizeY;
	}

	public static inline function mapToRange(value: FastFloat, fromLeft: FastFloat, fromRight: FastFloat, toLeft: FastFloat, toRight: FastFloat): FastFloat {
		return (value - fromLeft) * (toRight - toLeft) / (fromRight - fromLeft) + toLeft;
	}

	public static inline function clamp(value: FastFloat, minValue: FastFloat, maxValue: FastFloat): FastFloat {
		return Math.max(minValue, Math.min(maxValue, value));
	}

	public static inline function clampI(value: Int, minValue: Int, maxValue: Int): Int {
		return Std.int(Math.max(minValue, Math.min(maxValue, value)));
	}

	/**
	 * Round a value to the given precision.
	 *
	 * @param value The input value
	 * @param precision Number of decimal places
	 */
	public static function roundPrecision(value: FastFloat, precision = 0): FastFloat {
		value *= Math.pow(10, precision);
		value = Std.int(value);
		value /= Math.pow(10, precision);
		return value;
	}

	/**
	 * Calculate the sum of all elements of the given `kha.FastFloat` array.
	 */
	public static function arraySumF(array: Array<FastFloat>): FastFloat {
		var res: FastFloat = 0.0;
		for (elem in array) res += elem;
		return res;
	}

	/**
	 * Calculate the sum of all elements of the given integer array.
	 */
	public static function arraySumI(array: Array<Int>): Int {
		var res: Int = 0;
		for (elem in array) res += elem;
		return res;
	}

	/**
	 * Calculate the average value of all elements of the given `kha.FastFloat`
	 * array.
	 */
	public static inline function arrayAvgF(array: Array<FastFloat>): FastFloat {
		return array.length != 0 ? arraySumF(array) / array.length : 0.0;
	}

	/**
	 * Calculate the average value of all elements of the given integer array.
	 */
	public static inline function arrayAvgI(array: Array<Int>): FastFloat {
		return  array.length != 0 ? arraySumI(array) / array.length : 0.0;
	}
}
