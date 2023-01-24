package elements;

import utest.Assert;

import koui.elements.NumberInput;

class TestNumberInput extends utest.Test {
	var elem: NumberInput;
	var mockRecalcScrollBounds: FunctionMock;

	function setup() {
		elem = new NumberInput(TypeFloat);
		mockRecalcScrollBounds = new FunctionMock(elem, "recalcScrollBounds");
	}

	function teardown() {
		mockRecalcScrollBounds.unmock();
	}

	function test_set_inputType() {
		elem.inputType = TypeFloat;
		Assert.equals(elem.validationReg, NumberInput.REG_FLOAT);
		elem.inputType = TypeUnsignedFloat;
		Assert.equals(elem.validationReg, NumberInput.REG_UNSIGNED_FLOAT);
		elem.inputType = TypeInt;
		Assert.equals(elem.validationReg, NumberInput.REG_INT);
		elem.inputType = TypeUnsignedInt;
		Assert.equals(elem.validationReg, NumberInput.REG_UNSIGNED_INT);
	}

	function testSetFloatValue() {
		elem.inputType = TypeFloat;
		elem.setFloatValue(3.14);
		Assert.equals(elem.text, "3.14");
		elem.setFloatValue(-42);
		Assert.equals(elem.text, "-42");

		// Text value should not change
		elem.setFloatValue(Math.NaN);
		Assert.equals(elem.text, "-42");
		elem.setFloatValue(Math.POSITIVE_INFINITY);
		Assert.equals(elem.text, "-42");
		elem.setFloatValue(Math.NEGATIVE_INFINITY);
		Assert.equals(elem.text, "-42");
		elem.setFloatValue(null);
		Assert.equals(elem.text, "-42");

		elem.inputType = TypeInt;
		elem.setFloatValue(1.23);
		Assert.equals(elem.text, "1");
		elem.setFloatValue(-9.3);
		Assert.equals(elem.text, "-9");
	}

	function testGetFloatValue() {
		elem.setText("Hello");
		Assert.isTrue(Math.isNaN(elem.getFloatValue()));
		elem.setText("Infinity");
		Assert.isTrue(Math.isNaN(elem.getFloatValue()));

		elem.setText("3.14");
		Assert.floatEquals(elem.getFloatValue(), 3.14);
		elem.setText("-15");
		Assert.floatEquals(elem.getFloatValue(), -15.0);
	}

	function testGetFloatValueOrDefault() {
		elem.setText("Hello");
		Assert.floatEquals(elem.getFloatValueOrDefault(5.0), 5.0);
	}

	function testSetIntValue() {
		elem.setIntValue(-42);
		Assert.equals(elem.text, "-42");
		elem.setIntValue(null);
		Assert.equals(elem.text, "-42");
	}

	function testGetIntValue() {
		elem.setText("Hello");
		Assert.isNull(elem.getIntValue());
		elem.setText("Infinity");
		Assert.isNull(elem.getIntValue());

		elem.setText("3.14");
		Assert.equals(elem.getIntValue(), 3);
		elem.setText("-9.3");
		Assert.equals(elem.getIntValue(), -9);
	}

	function testGetIntValueOrDefault() {
		elem.setText("Hello");
		Assert.equals(elem.getIntValueOrDefault(31), 31);
	}
}
