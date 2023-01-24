package theme;

import haxe.ds.Map;

import kha.Color;
import utest.Assert;

import koui.theme.parser.ThemeParser;

@:access(koui.theme.parser.ThemeParser)
class TestThemeParser extends utest.Test {
	function setup() {
		// Reset parserState and parser out
		ThemeParser.initParser(false);
	}

	function teardown() {}

	function testResolveExtensions() {
		var selector = ParserTestUtils.newSelector("TestSelector", "!default", true, null);
		selector.map["attr1"] = EValue({
			path: "TestSelector!default.attr1",
			type: "Float",
			valueStr: "3.14",
			reference: null,
			value: 3.14,
			inherited: false
		});

		// Should not do anything, extensions are already resolved;
		ThemeParser.resolveExtensions(selector);

		var extension = ParserTestUtils.newSelector("Extended", "!default", true, null);
		extension.map["attr1"] = EValue({
			path: "Extended!default.attr1",
			type: "Float",
			valueStr: "42",
			reference: null,
			value: 42,
			inherited: false
		});
		extension.map["attr2"] = EValue({
			path: "Extended!default.attr1",
			type: "String",
			valueStr: "Hello world!",
			reference: null,
			value: "Hello world!",
			inherited: false
		});

		selector.resolvedExtensions = false;
		selector.extending = "Extended!default";

		// =====================================================================
		// Test basic extensions
		// =====================================================================
		ThemeParser.resolveExtensions(selector);

		switch (selector.map["attr1"]) {
			case EValue(tValue):
				Assert.equals(tValue.value, 3.14);
				Assert.equals(tValue.inherited, false);
			case null:
				Assert.fail("Selector attribute is null");
			default:
				Assert.fail("Wrong node type in selector map");
		}

		switch (selector.map["attr2"]) {
			case EValue(tValue):
				Assert.equals(tValue.value, "Hello world!");
				Assert.equals(tValue.inherited, true);
			case null:
				Assert.fail("Selector attribute is null");
			default:
				Assert.fail("Wrong node type in selector map");
		}

		// =====================================================================
		// Raise on invalid reference to a non-existing extension
		// =====================================================================
		selector.extending = "doesNotExist";
		Assert.raises(() -> ThemeParser.resolveExtensions(selector));
	}

	function testResolveStates() {
		var selector = ParserTestUtils.newSelector("TestSelector", "!default", false, null);
		selector.map["attr1"] = EValue({
			path: "TestSelector!default.attr1",
			type: "Float",
			valueStr: "3.14",
			reference: null,
			value: 3.14,
			inherited: false
		});

		// Should not do anything, extensions are already resolved;
		ThemeParser.resolveStates(selector);
		selector.resolvedExtensions = false;
		// Still should not do anything for default state
		ThemeParser.resolveStates(selector);

		var selectorHover = ParserTestUtils.newSelector("TestSelector", "!hover", true, null);

		// =====================================================================
		// Test basic state resolving
		// =====================================================================
		Assert.isNull(selectorHover.map["attr1"]);

		selectorHover.resolvedExtensions = false;
		ThemeParser.resolveStates(selectorHover);

		switch (selectorHover.map["attr1"]) {
			case EValue(tValue):
				Assert.equals(tValue.value, 3.14);
				Assert.equals(tValue.inherited, true);
			case null:
				Assert.fail("Selector attribute is null");
			default:
				Assert.fail("Wrong node type in selector map");
		}

		// =====================================================================
		// Raise on missing default state
		// =====================================================================
		ThemeParser.out.selectors.remove(selector.name);

		selectorHover.resolvedExtensions = false;
		Assert.raises(() -> ThemeParser.resolveStates(selectorHover));

		ThemeParser.out.selectors.set(selector.name, selector);

		// =====================================================================
		// First merge same state extended selectors, then the default one
		// =====================================================================
		var extendedDefault = ParserTestUtils.newSelector("Extended", "!default", true, null);
		extendedDefault.map["attr1"] = EValue({
			path: "Extended!default.attr1",
			type: "Float",
			valueStr: "1.0",
			reference: null,
			value: 1.0,
			inherited: false
		});
		extendedDefault.map["attr2"] = EValue({
			path: "Extended!default.attr2",
			type: "String",
			valueStr: "Hello world!",
			reference: null,
			value: "Hello world!",
			inherited: false
		});

		// Setup correct hover map
		var extendedHover = ParserTestUtils.newSelector("Extended", "!hover", false, null);
		selector.resolvedExtensions = false;
		ThemeParser.resolveStates(extendedHover);

		selector.extending = "Extended!default";

		selectorHover.map = new Map<String, Node>();
		selectorHover.resolvedExtensions = false;

		ThemeParser.resolveStates(selectorHover);

		// Keep value from same selector with default state
		switch (selectorHover.map["attr1"]) {
			case EValue(tValue):
				Assert.equals(tValue.value, 3.14);
				Assert.equals(tValue.inherited, true);
			case null:
				Assert.fail("Selector attribute is null");
			default:
				Assert.fail("Wrong node type in selector map");
		}

		// Because the value doesn't exist on the default state, use the
		// extended selector with the same state (hover)
		switch (selectorHover.map["attr2"]) {
			case EValue(tValue):
				Assert.equals(tValue.value, "Hello world!");
				Assert.equals(tValue.inherited, true);
			case null:
				Assert.fail("Selector attribute is null");
			default:
				Assert.fail("Wrong node type in selector map");
		}
	}

	function testCreateRequiredStates() {
		ParserTestUtils.newSelector("TestSelector", "!default", false, null);
		ParserTestUtils.newSelector("TestSelector", "!hover", false, null);
		ParserTestUtils.newSelector("TestSelector", "!click", false, null);
		var selectorExtending = ParserTestUtils.newSelector("Extending", "!default", false, "TestSelector!default");

		// Do nothing, newSelector() returns a selector with `hasAllStates = true`
		ThemeParser.createRequiredStates(selectorExtending);
		Assert.notNull(ThemeParser.out.selectors["Extending!default"]);
		Assert.isNull(ThemeParser.out.selectors["Extending!hover"]);
		Assert.isNull(ThemeParser.out.selectors["Extending!click"]);

		selectorExtending.hasAllStates = false;
		ThemeParser.createRequiredStates(selectorExtending);
		Assert.notNull(ThemeParser.out.selectors["Extending!hover"]);
		Assert.notNull(ThemeParser.out.selectors["Extending!default"]);
		Assert.notNull(ThemeParser.out.selectors["Extending!click"]);

		Assert.isTrue(selectorExtending.hasAllStates);

		// Also do nothing, the createRequiredStates() only uses default selectors
		var selectorExtending2 = ParserTestUtils.newSelector("Extending2", "!hover", false, "TestSelector!hover");
		ThemeParser.createRequiredStates(selectorExtending2);
		Assert.isNull(ThemeParser.out.selectors["Extending2!default"]);
		Assert.notNull(ThemeParser.out.selectors["Extending2!hover"]);
		Assert.isNull(ThemeParser.out.selectors["Extending2!click"]);
	}

	function testValidateNoKeyword() {
		Assert.raises(() -> ThemeParser.validateNoKeyword("default"));
		ThemeParser.validateNoKeyword("Hello");
	}

	function testTraverseByPath() {
		var map0 = new Map<String, Node>();
		var map1 = new Map<String, Node>();
		var map2 = new Map<String, Node>();
		map0.set("1", EGroup({path: "", optional: false, map: map1}));
		map1.set("2", EGroup({path: "", optional: false, map: map2}));
		map2.set("3", EType("Float"));

		Assert.same(ThemeParser.traverseByPath(map0, ["1", "2", "3"]), EType("Float"));
		Assert.same(ThemeParser.traverseByPath(map0, ["1", "2"]), EGroup({path: "", optional: false, map: map2}));

		Assert.raises(() -> ThemeParser.traverseByPath(map0, [""]));
		Assert.raises(() -> ThemeParser.traverseByPath(map0, ["1", "3"]));
	}

	function testUnindent() {
		var outStack = ThemeParser.parserState.outputStack;
		var pathStack = ThemeParser.parserState.pathStack;

		// This stack makes no sense but is sufficient for this test (EType does
		// not require a typedef in its constructor)
		outStack.add(EType("BaseNode"));
		outStack.add(EType("Int"));
		outStack.add(EType("Float"));
		pathStack.add("1");
		pathStack.add("2");

		// indentLevel is bigger than lastIndentLevel so nothing should happen
		ThemeParser.unindent(2, 0);
		Assert.same(outStack.first(), EType("Float"));
		Assert.equals(pathStack.first(), "2");

		ThemeParser.unindent(0, 2);
		// // The base node should remain, but all other nodes should be popped
		Assert.same(outStack.first(), EType("BaseNode"));
		Assert.isTrue(pathStack.isEmpty());

		outStack.add(EType("BaseNode"));
		outStack.add(EType("Int"));
		outStack.add(EType("Float"));
		pathStack.add("1");
		pathStack.add("2");

		ThemeParser.unindent(2, 2);
		Assert.same(outStack.first(), EType("Float"));
		Assert.equals(pathStack.first(), "1");

		// Now, the stack is too small
		ThemeParser.unindent(0, 4);
		Assert.isNull(outStack.head);
		Assert.isNull(pathStack.head);
	}

	function testCalculateIndentation() {
		var indentStack = ThemeParser.parserState.indentStack;

		indentStack.add(1);

		ThemeParser.calculateIndentation(2);
		Assert.equals(ThemeParser.parserState.indentStack.first(), 2);

		Assert.raises(() -> ThemeParser.calculateIndentation(4));

		ThemeParser.parserState.lastLineType = Definition;
		Assert.raises(() -> ThemeParser.calculateIndentation(3));

		// Nothing should happen, current indentation level is 2 already
		indentStack.add(2);

		indentStack.add(0);
		Assert.equals(indentStack.first(), 0);
	}

	function testPathToString() {
		Assert.equals(ThemeParser.pathToString(["1", "2", "3"]), "1.2.3");
		Assert.equals(ThemeParser.pathToString(["1", "2", "2"]), "1.2.2");
		Assert.equals(ThemeParser.pathToString(["1"]), "1");

		var pathStack = ThemeParser.parserState.pathStack;
		pathStack.add("1");
		pathStack.add("2");
		pathStack.add("3");
		Assert.equals(ThemeParser.pathToString(), "1.2.3");
	}

	function testGetCurrentPath() {
		var pathStack = ThemeParser.parserState.pathStack;
		pathStack.add("1");
		pathStack.add("2");
		pathStack.add("3");

		Assert.same(ThemeParser.getCurrentPath(), ["1", "2", "3"]);
	}

	function testParseString() {
		// Strings must have "" around them, unescaping is tested in
		// utils/TestStringUtil.hx
		Assert.raises(() -> ThemeParser.parseString("test"));
		Assert.raises(() -> ThemeParser.parseString("\"test"));
		Assert.raises(() -> ThemeParser.parseString("test\""));

		Assert.equals(ThemeParser.parseString("\"test\""), "test");
	}

	function testParseInt() {
		Assert.raises(() -> ThemeParser.parseInt("hello"));

		Assert.equals(ThemeParser.parseInt("4"), 4);
		Assert.equals(ThemeParser.parseInt("4.3"), 4);
		Assert.equals(ThemeParser.parseInt("-4.3"), -4);
	}

	function testParseFloat() {
		Assert.raises(() -> ThemeParser.parseFloat("hello"));

		Assert.equals(ThemeParser.parseFloat("4"), 4.0);
		Assert.equals(ThemeParser.parseFloat("4.3"), 4.3);
		Assert.equals(ThemeParser.parseFloat("-4.3"), -4.3);
	}

	function testParseColor() {
		Assert.raises(() -> ThemeParser.parseColor("hello"));
		Assert.raises(() -> ThemeParser.parseColor("#ff"));
		Assert.raises(() -> ThemeParser.parseColor("#ffaabbccdd"));
		Assert.raises(() -> ThemeParser.parseColor("#aabbxxyy"));

		Assert.same(ThemeParser.parseColor("#012345"), Color.fromString("#ff012345"));
		Assert.same(ThemeParser.parseColor("#01234567"), Color.fromString("#67012345"));
		Assert.same(ThemeParser.parseColor("#AABBCC"), Color.fromString("#ffaabbcc"));
	}

	function testParseBool() {
		Assert.isTrue(ThemeParser.parseBool("true"));
		Assert.isTrue(ThemeParser.parseBool("TRUE"));
		Assert.isTrue(ThemeParser.parseBool("tRuE"));
		Assert.isFalse(ThemeParser.parseBool("false"));
		Assert.isFalse(ThemeParser.parseBool("FALSE"));
		Assert.isFalse(ThemeParser.parseBool("fAlSe"));

		Assert.raises(() -> ThemeParser.parseBool("hello"));
	}
}
