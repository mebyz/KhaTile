package koui.elements;

/**
	Interface for elements which hold values in a certain (numeric) range.
**/
interface I_Range<T> {
	/**
			The current value (in the interval `[minValue, maxValue]`).
	**/
	public var value(default, set): T;

	/**
		The smallest possible value of this range.
	**/
	public var minValue(default, set): T;

	/**
		The largest possible value of this range.
	**/
	public var maxValue(default, set): T;
}
