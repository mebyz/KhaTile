package elements;

import utest.Assert;

import koui.elements.TextInput;

class TestTextInput extends utest.Test {
	var elem: TextInput;
	var mockRecalcScrollBounds: FunctionMock;

	function setup() {
		this.elem = new TextInput("InputLabel");
		mockRecalcScrollBounds = new FunctionMock(elem, "recalcScrollBounds");
	}

	function teardown() {
		mockRecalcScrollBounds.unmock();
	}

	function testIsTextSelected() {
		elem.setText("Example text");
		Assert.isFalse(elem.isTextSelected());
		elem.selectAll();
		Assert.isTrue(elem.isTextSelected());
		elem.setText("");
		elem.selectAll();
		Assert.isFalse(elem.isTextSelected());
	}

	function testGetSelectedText() {
		elem.setText("Test");
		Assert.equals(elem.getSelectedText(), "");
		elem.selectAll();
		Assert.equals(elem.getSelectedText(), "Test");
	}

	function testDeleteSelectedText() {
		elem.setText("Test");
		elem.deleteSelectedText();
		Assert.equals(elem.text, "Test");
		elem.selectAll();
		elem.deleteSelectedText();
		Assert.equals(elem.text, "");
	}


	function testInsertText() {
		elem.setText("123456789");
		elem.insertText("insert", 0);
		Assert.equals(elem.text, "insert123456789");

		elem.insertText("abc", 4);
		Assert.equals(elem.text, "inseabcrt123456789");

		elem.insertText("nope", 100);
		Assert.equals(elem.text, "inseabcrt123456789nope");

		elem.maxLength = 50;
		elem.insertText("max", 100);
		Assert.equals(elem.text, "inseabcrt123456789nope");

		// This also tests truncateMaxLength()
		elem.setText("123");
		elem.maxLength = 5;
		elem.insertText("456789", 3);
		Assert.equals(elem.text, "12345");
	}
}
