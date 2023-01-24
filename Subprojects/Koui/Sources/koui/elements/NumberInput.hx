package koui.elements;

/**
 * A number input is a special kind of text input that only accepts numbers. The
 * type of number it accepts is specified by its `NumberInput.inputType`.
 *
 * ![NumberInput screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_numberinput.png)
 *
 * @see `TextInput`
 */
class NumberInput extends TextInput {
	/**
	 * The regular expression used to check whether a string is a valid
	 * signed floating point number. Note that the decimal separator is a
	 * decimal point(`.`) as it is common in the English language.
	 *
	 * It also accepts strings beginning with a `+` or `-` sign.
	 *
	 * @see [`REG_UNSIGNED_FLOAT`](#REG_UNSIGNED_FLOAT)
	 */
	public static final REG_FLOAT = ~/^[\-\+]?[0-9]+(\.[0-9]+)?$/gm;
	/**
	 * The regular expression used to check whether a string is a valid signed
	 * integer number.
	 *
	 * It also accepts strings beginning with a `+` or `-` sign.
	 *
	 * @see [`REG_UNSIGNED_INT`](#REG_UNSIGNED_INT)
	 */
	public static final REG_INT = ~/^[\-\+]?[0-9]+$/gm;

	/**
	 * The regular expression used to check whether a string is a valid
	 * unsigned floating point number. Note that the decimal separator is a
	 * decimal point(`.`) as it is common in the English language.
	 *
	 * It also accepts strings beginning with a `+` sign.
	 *
	 * @see [`REG_INT`](#REG_INT)
	 */
	public static final REG_UNSIGNED_FLOAT = ~/^[\+?[0-9]+(\.[0-9]+)?$/gm;

	/**
	 * The regular expression used to check whether a string is a valid unsigned
	 * integer number.
	 *
	 * It also accepts strings beginning with a `+` sign.
	 *
	 * @see [`REG_FLOAT`](#REG_FLOAT)
	 */
	public static final REG_UNSIGNED_INT = ~/^\+?[0-9]+$/gm;

	/**
	 * The number type that is accepted by this `NumberInput`.
	 */
	public var inputType(default, set) = NumberType.TypeFloat;

	/**
	 * Create a new `NumberInput` element.
	 */
	public function new(inputType: NumberType, label: String = "") {
		super(label);
		this.inputType = inputType;
	}

	function set_inputType(value: NumberType) {
		this.inputType = value;

		this.validationReg = switch (value) {
			case TypeFloat: REG_FLOAT;
			case TypeUnsignedFloat: REG_UNSIGNED_FLOAT;
			case TypeInt: REG_INT;
			case TypeUnsignedInt: REG_UNSIGNED_INT;
		}

		return this.inputType;
	}

	/**
	 * Set the floating point value of this element. If this number input
	 * accepts integer vaues only, the decimal places of the given value are
	 * truncated towards zero. If the given value is not a finite number
	 * (`Math.NaN`, `Math.POSIIVE_INIFINITY` etc.) or `null` (possible on
	 * non-static targets only), nothing will happen.
	 */
	public function setFloatValue(value: Null<Float>) {
		if (!Math.isFinite(value) || value == null) return;
		if (inputType == TypeInt || inputType == TypeUnsignedInt) {
			value = (value > 0) ? Math.ffloor(value) : Math.fceil(value);
		}
		this.text = Std.string(value);
	}

	/**
	 * Return the floating point value of this element. If the input is
	 * invalid, `Math.NaN` is returned. This function is equivalent to
	 * `getFloatValueOrDefault(Math.NaN)`.
	 *
	 * @see [`getFloatValueOrDefault()`](#getFloatValueOrDefault)
	 */
	public function getFloatValue(): Float {
		if (!valid) return Math.NaN;
		return Std.parseFloat(text);
	}

	/**
	 * Return the floating point value of this element. If the input is
	 * invalid, the given default value is returned.
	 *
	 * @see [`getFloatValue()`](#getFloatValue)
	 */
	public function getFloatValueOrDefault(defaultValue: Float = 0.0): Float {
		if (!valid) return defaultValue;
		return Std.parseFloat(text);
	}

	/**
	 * Set the integer value of this element. If the given value is `null`
	 * (possible on non-static targets only), nothing will happen.
	 *
	 * @param value The new value
	 */
	public function setIntValue(value: Null<Int>) {
		if (value == null) return;
		this.text = Std.string(value);
	}

	/**
	 * Return the integer value of this element. If the input is invalid,
	 * `null` is returned (make sure to test this in your code!).
	 *
	 * @see [`getIntValueOrDefault()`](#getIntValueOrDefault)
	 */
	public function getIntValue(): Null<Int> {
		if (!valid) return null;
		return Std.parseInt(text);
	}

	/**
	 * Return the integer value of this element. If the input is invalid, the
	 * given default value is returned.
	 *
	 * @see [`getIntValue()`](#getIntValue)
	 */
	public function getIntValueOrDefault(defaultValue: Int = 0): Int {
		if (!valid) return defaultValue;
		return Std.parseInt(text);
	}
}

/**
 * Represents a number type used to describe what numbers a `NumberInput`
 * element accepts.
 */
enum abstract NumberType(Int) {
	/**
	 * Represents a signed floating point number.
	 */
	var TypeFloat;

	/**
	 * Represents an unsigned floating point number.
	 */
	var TypeUnsignedFloat;

	/**
	 * Represents a signed integer number.
	 */
	var TypeInt;

	/**
	 * Represents an unsigned integer number.
	 */
	var TypeUnsignedInt;
}
