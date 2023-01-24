package elements;

import utest.Assert;

import koui.elements.Slider;
import koui.events.ValueChangeEvent;

class TestSlider extends utest.Test {
	var elem: Slider;
	var dispatchedValueChangeEvent = false;

	function setup() {
		elem = new Slider(0, 100);

		elem.addEventListener(ValueChangeEvent, _valueChanged);
		dispatchedValueChangeEvent = false;
	}

	function teardown() {}

	function _valueChanged(e: ValueChangeEvent) {
		dispatchedValueChangeEvent = true;
	}

	function test_set_orientation() {
		final handle = @:privateAccess elem.cElemHandle;

		elem.orientation = SliderOrientation.Right;
		Assert.equals(0.0, handle.posX);
		Assert.equals(0.0, handle.posY);
		Assert.isTrue(elem.isHorizontal());

		elem.orientation = SliderOrientation.Left;
		Assert.floatEquals(elem.width - handle.width, handle.posX);
		Assert.equals(0.0, handle.posY);
		Assert.isTrue(elem.isHorizontal());

		elem.orientation = SliderOrientation.Up;
		Assert.equals(0.0, handle.posX);
		Assert.floatEquals(elem.height - handle.height, handle.posY);
		Assert.isFalse(elem.isHorizontal());

		elem.orientation = SliderOrientation.Down;
		Assert.equals(0.0, handle.posX);
		Assert.equals(0.0, handle.posY);
		Assert.isFalse(elem.isHorizontal());

		Assert.isFalse(dispatchedValueChangeEvent);
	}

	function test_set_value() {
		final handle = @:privateAccess elem.cElemHandle;

		elem.value = 0;
		Assert.equals(0, elem.value);
		Assert.isTrue(dispatchedValueChangeEvent);

		// Also call event listener if values don't change
		dispatchedValueChangeEvent = false;
		elem.value = 0;
		Assert.isTrue(dispatchedValueChangeEvent);

		dispatchedValueChangeEvent = false;
		elem.value = -11;
		Assert.equals(0, elem.value);
		Assert.floatEquals(0, handle.posY);
		Assert.isTrue(dispatchedValueChangeEvent);

		dispatchedValueChangeEvent = false;
		elem.value = 199;
		Assert.equals(100, elem.value);
		Assert.floatEquals(elem.width - handle.width, handle.posX);
		Assert.isTrue(dispatchedValueChangeEvent);

		dispatchedValueChangeEvent = false;
		elem.value = 50;
		Assert.equals(50, elem.value);
		Assert.floatEquals(elem.width / 2 - handle.width / 2, handle.posX);
		Assert.isTrue(dispatchedValueChangeEvent);

		#if !target.static
		dispatchedValueChangeEvent = false;
		elem.minValue = 20;
		elem.value = null;
		Assert.equals(elem.minValue, elem.value);
		Assert.isTrue(dispatchedValueChangeEvent);
		#end
	}

	function test_set_min_max() {
		final handle = @:privateAccess elem.cElemHandle;

		elem.value = 10;

		dispatchedValueChangeEvent = false;
		elem.minValue = 10;
		Assert.equals(0, handle.posX);
		Assert.isFalse(dispatchedValueChangeEvent);

		elem.minValue = 20;
		Assert.equals(20, elem.value);
		Assert.equals(0, handle.posX);
		Assert.isTrue(dispatchedValueChangeEvent);

		elem.value = 44;
		dispatchedValueChangeEvent = false;
		elem.maxValue = 42;
		Assert.equals(42, elem.value);
		Assert.floatEquals(elem.width - handle.width, handle.posX);
		Assert.isTrue(dispatchedValueChangeEvent);

		elem.maxValue = 200;
		elem.minValue = 100;
		Assert.raises(() -> {elem.maxValue = 99;});
	}
}
