package koui.theme.parser;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;
#if macro
import sys.io.FileInput;
#end

import kha.Color;

import koui.utils.Log;
import koui.utils.Set;

using Lambda;
using StringTools;
using koui.utils.StringUtil;

class ThemeParser {
	static final regIndent = ~/^(\t*)(.*)$/i;
	static final regEmpty = ~/^[ \t]*(\/\/.*)?$/i;
	// groupName!stateName: value
	static final lineReg = ~/^([\w\-]+)(![\w\-]+)?( *> *([\w\-]+))? *: *(.*)$/i;
	static final ruleReg = ~/^(\?)?([\w\-]+) *: *(.*)$/i;
	static final rulesReg = ~/^@rules( )*:( )*$/i;
	static final globalsReg = ~/^(@globals)( )*:( )*$/i;
	static final regColor = ~/^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})?$/i;

	static final validTypes = ["Asset", "Bool", "Color", "Float", "Int", "String"];
	static final reservedKeywords = [
		"abstract",
		"break",
		"case",
		"cast",
		"catch",
		"class",
		"continue",
		"default",
		"do",
		"dynamic",
		"else",
		"enum",
		"extends",
		"extern",
		"false",
		"final",
		"for",
		"function",
		"if",
		"implements",
		"import",
		"in",
		"inline",
		"interface",
		#if (haxe_ver >= 4.2)
		"is",
		#end
		"macro",
		"new",
		"null",
		"operator",
		"overload",
		"override",
		"package",
		"private",
		"public",
		"return",
		"static",
		"switch",
		"this",
		"throw",
		"true",
		"try",
		"typedef",
		"untyped",
		"using",
		"var",
		"while"
	];

	static var parserState: TParserState;
	static var out: TOutput;

	#if macro
	public static function parseFile(file: FileInput, consecutiveRun = false): TOutput {
		#if KOUI_PROFILE_THEME_PARSER
		var startTime = Sys.time();
		#end
		Log.out("Parsing theme file");

		initParser(consecutiveRun);

		var eof = false;
		while (!eof) {
			parserState.currentLine++;

			var line = "";
			try {
				line = file.readLine();
			}
			catch (e: haxe.io.Eof) {
				eof = true;
				continue;
			}

			// Ignore empty lines and comments
			if (line == "" || regEmpty.match(line)) {
				continue;
			}

			try {
				parseLine(line);
			}
			catch (e: String) {
				file.close();
				var exc = '\n| ThemeParserError: $e\n';
				exc += '| Line ${parserState.currentLine}: ${line}\n';
				exc += '| Stack: ${haxe.CallStack.toString(haxe.CallStack.exceptionStack())}\n';
				exc += "| -----";
				throw exc;
			}
		}
		file.close();

		#if KOUI_PROFILE_THEME_PARSER
		Log.out('Theme file parsing took ${Sys.time() - startTime}s');
		#else
		Log.out("Theme file parsing done");
		#end

		return out;
	}

	/**
	 * Make sure that all selectors correctly inherit from their extended
	 * selectors and states and make sure that all required states exist.
	 */
	public static function resolveTheme(): Void {
		Log.out("Resolving references and extensions");
		for (tValue in out.references) {
			// Already resolved the reference
			if (tValue.reference == null) continue;

			try {
				resolveReferences(tValue);
			}
			catch (e: String) {
				var exc = '\n| ThemeParserError: $e\n';
				exc += '| Definition path: ${tValue.path}\n';
				exc += '| References: ${tValue.reference}\n';
				exc += '| Stack: ${haxe.CallStack.toString(haxe.CallStack.exceptionStack())}\n';
				exc += "| -----";
				throw exc;
			}
		}

		for (selector in out.selectors) {
			createRequiredStates(selector);
		}

		for (selector in out.selectors) {
			if (selector.resolvedExtensions) continue;

			try {
				resolveExtensions(selector);
				resolveStates(selector);
			}
			catch (e: String) {
				var exc = '\n| ThemeParserError: $e\n';
				exc += '| Selector: ${selector.name} > ${selector.extending}\n';
				exc += '| Stack: ${haxe.CallStack.toString(haxe.CallStack.exceptionStack())}\n';
				exc += "| -----";
				throw exc;
			}
		}

		cleanup();
	}

	/**
	 * Cleanup, don't include globals section in styles
	 */
	public static function cleanup() {
		// TODO: Copy globals into static Style map
		out.props.remove("@globals!default");
		out.selectors.remove("@globals!default");
		out.selectorStates.remove("@globals");
	}
	#end

	static function initParser(consecutiveRun: Bool): Void {
		parserState = {
			currentLine: 0,
			foundRules: false,
			visitingGlobals: false,
			visitingRules: false,
			indentStack: new GenericStack<Int>(),
			outputStack: new GenericStack<Node>(),
			pathStack: new GenericStack<String>(),
			lastLineType: None,
			consecutiveRun: consecutiveRun
		};

		// https://docs.python.org/3/reference/lexical_analysis.html#indentation
		parserState.indentStack.add(0);

		if (!consecutiveRun) {
			out = {
				rules: new Map<String, Node>(),
				props: new Map<String, Dynamic>(),
				selectors: new Map<String, TSelector>(),
				references: new Array<TValue>(),
				selectorStates: new Map<String, Array<String>>(),
				assetNames: new Set()
			};
		}
	}

	static function parseLine(line: String) {
		if (!parserState.foundRules) {
			// Enter @rules block
			if (rulesReg.match(line)) {
				parserState.foundRules = true;
				parserState.visitingRules = true;

				var tRulesGroup: TGroup = {path: "", optional: false, map: out.rules}
				parserState.outputStack.add(EGroup(tRulesGroup));
				return;
			}
			else {
				if (!parserState.consecutiveRun) {
					throw "File must start with @rules definitions!";
				}
			}
		}

		if (!regIndent.match(line)) {
			throw "Syntax error: could not match indentation!";
		}

		// Get indentation level
		line = regIndent.matched(2);
		if (line.ltrim() != line) {
			throw "Syntax error: tabs must be used for indentation!";
		}

		var indentLevel = regIndent.matched(1).length;
		var lastIndentLevel = parserState.indentStack.first();
		calculateIndentation(indentLevel);

		// Exit @rules block
		if (parserState.visitingRules && indentLevel == 0) {
			parserState.visitingRules = false;
		}
		// Exit @globals block
		if (parserState.visitingGlobals && indentLevel == 0) {
			parserState.visitingGlobals = false;
		}

		if (parserState.visitingRules && ruleReg.match(line)) {
			parseRule(ruleReg, indentLevel, lastIndentLevel);
		}
		else if (!parserState.visitingRules) {
			if (globalsReg.match(line)) {
				parserState.visitingGlobals = true;
				parseProperty(globalsReg, indentLevel, lastIndentLevel, true);
			}
			else if (lineReg.match(line)) {
				parseProperty(lineReg, indentLevel, lastIndentLevel);
			}
			else {
				throw "Syntax error!";
			}
		}
		else {
			throw "Syntax error!";
		}
	}

	static function parseRule(matchedReg: EReg, indentLevel: Int, lastIndentLevel: Int) {
		var matchedOptional = matchedReg.matched(1);
		var matchedGroup = matchedReg.matched(2);
		var matchedType = matchedReg.matched(3);

		validateNoKeyword(matchedGroup);

		// Group objects
		if (matchedType == "") {
			var tGroup = parseGroup(matchedGroup, indentLevel, lastIndentLevel);
			if (matchedOptional == "?") {
				tGroup.optional = true;
			}
			#if KOUI_DEBUG_THEME_PARSER
			debugLine(lastIndentLevel, matchedGroup, matchedType);
			#end
		}

		// Actual rules
		else {
			unindent(indentLevel, lastIndentLevel);
			parserState.pathStack.add(matchedGroup);

			if (!validTypes.has(matchedType)) {
				throw 'The type of rule "${pathToString()}" is not supported! Type: "$matchedType"';
			}

			switch (parserState.outputStack.first()) {
				case EGroup(tGroup):
					tGroup.map.set(matchedGroup, EType(matchedType));
				default:
					throw "Internal error!";
			}

			parserState.lastLineType = Definition;
			#if KOUI_DEBUG_THEME_PARSER
			debugLine(lastIndentLevel, matchedGroup, matchedType);
			#end
		}
	}

	static function parseProperty(matchedReg: EReg, indentLevel: Int, lastIndentLevel: Int, globalSelector = false) {
		var matchedGroup = matchedReg.matched(1);
		var matchedState = matchedReg.matched(2);

		var matchedExtends: Null<String> = null;
		var matchedValue: String = "";

		// globalsReg has not enough groups to parse
		if (!globalSelector) {
			matchedExtends = matchedReg.matched(4);
			matchedValue = matchedReg.matched(5);
		}

		validateNoKeyword(matchedGroup);

		if (indentLevel == 0) {
			parseSelector(matchedGroup, matchedState, matchedExtends, matchedValue);
			#if KOUI_DEBUG_THEME_PARSER
			debugLine(lastIndentLevel, matchedGroup, matchedValue);
			#end
			return;
		}

		// Group objects
		if (matchedValue == "") {
			if (parserState.visitingGlobals) {
				throw "Groups are not allowed in @globals section!";
			}
			else {
				var tGroup = parseGroup(matchedGroup, indentLevel, lastIndentLevel);

				var path = getCurrentPath();
				// Remove selector from path
				path.shift();
				switch (traverseByPath(out.rules, path)) {
					case EGroup(tRuleGroup):
						tGroup.optional = tRuleGroup.optional;
					default:
						throw "Internal error!";
				}

				#if KOUI_DEBUG_THEME_PARSER
				debugLine(lastIndentLevel, matchedGroup, matchedValue);
				#end
			}
		}

		// Actual property definitions
		else {
			unindent(indentLevel, lastIndentLevel);
			parserState.pathStack.add(matchedGroup);

			switch (parserState.outputStack.first()) {
				case EGroup(tGroup):
					tGroup.map.set(matchedGroup, Node.EValue(parseValue(matchedValue)));
				case ESelector(tSelector):
					tSelector.map.set(matchedGroup, Node.EValue(parseValue(matchedValue)));
				default:
					throw "Internal error!";
			}

			parserState.lastLineType = Definition;
			#if KOUI_DEBUG_THEME_PARSER
			debugLine(lastIndentLevel, matchedGroup, matchedValue);
			#end
		}

		if (indentLevel != 0 && matchedExtends != null) {
			throw 'Extension not supported for non-selectors: ${pathToString()}';
		}
	}

	static function parseSelector(selectorName: String, state: String, extending: String, value: String) {
		// Clear path
		parserState.pathStack = new GenericStack<String>();
		parserState.pathStack.add(selectorName);

		if (selectorName == "_root" || selectorName == "@globals") {
			if (extending != null) {
				throw 'Selector $selectorName is not allowed to extend another selector!';
			}
		}
		else if (state == null && extending == null) {
			throw 'Default state selector must extend _root or extension of _root! Path: ${pathToString()}';
		}

		if (selectorName == extending) {
			throw 'Selectors are not allowed to extend themselves! Path: ${pathToString()}';
		}

		if (extending != null && state != null && state != "!default") {
			throw 'Extending selector must not have a state other than "default"! Path: ${pathToString()}';
		}

		// Now that the path is correct we can check for errors
		if (value != "") {
			throw 'Selector must not have a value! Path: ${pathToString()}';
		}

		if (state == null) state = "!default";
		registerSelectorState(selectorName, state);

		var tSelector: TSelector;
		if (out.selectors.exists(selectorName + state)) {
			tSelector = out.selectors.get(selectorName + state);
		}
		else {
			var selectorMap = new Map<String, Node>();
			tSelector = {
				name: selectorName + state,
				map: selectorMap,
				resolvedExtensions: (extending == null && state == "!default"),
				hasAllStates: (extending == null),
				pureName: selectorName,
				state: state,
				// `extending` is not `null` only in "!default" state, states are
				// resolved later
				extending: (extending == null) ? null : (extending + "!default")
			};
			out.selectors.set(tSelector.name, tSelector);
		}

		// Clear output stack
		parserState.outputStack = new GenericStack<Node>();
		parserState.outputStack.add(Node.ESelector(tSelector));

		// Add this selector to the properties output
		out.props.set(tSelector.name, tSelector.map);

		parserState.lastLineType = Selector;
	}

	static function parseGroup(groupName: String, indentLevel: Int, lastIndentLevel: Int): TGroup {
		unindent(indentLevel, lastIndentLevel);

		parserState.pathStack.add(groupName);

		var nodeGroup: Node = null;
		var tGroup: TGroup;
		switch (parserState.outputStack.first()) {
			case EGroup(tG):
				nodeGroup = tG.map.get(groupName);
			case ESelector(tSelector):
				nodeGroup = tSelector.map.get(groupName);
			default:
				throw "Internal error!";
		}

		// If the group already exists
		if (nodeGroup != null) {
			switch (nodeGroup) {
				case EGroup(tG):
					tGroup = tG;
				default:
					throw "Internal error!";
			}
		}
		else {
			// Map containing the definitions or sub-groups for this group
			var subMap = new Map<String, Node>();

			tGroup = {
				path: pathToString(),
				optional: false,
				map: subMap
			}
			nodeGroup = Node.EGroup(tGroup);

			// Put new definition map on the stack
			switch (parserState.outputStack.first()) {
				case EGroup(tG):
					tG.map.set(groupName, nodeGroup);
				case ESelector(tSelector):
					tSelector.map.set(groupName, nodeGroup);
				default:
					throw "Internal error!";
			}
		}

		if (nodeGroup == null) {
			throw "Internal error!";
		}

		parserState.outputStack.add(nodeGroup);
		parserState.lastLineType = Group;

		return tGroup;
	}

	static function parseValue(valueStr: String): TValue {
		var path = getCurrentPath();
		path.shift();

		if (parserState.visitingGlobals) {
			return {path: pathToString(), type: "", valueStr: valueStr, inherited: false};
		}

		var typeNode = traverseByPath(out.rules, path);

		var tValue: TValue = {
			path: pathToString(),
			type: "",
			valueStr: valueStr,
			inherited: false
		}

		switch (typeNode) {
			case EType(typeStr):
				tValue.type = typeStr;
			default:
				throw "Internal error!";
		}

		// Property references another property
		if (valueStr.startsWith("$")) {
			tValue.reference = valueStr.substr(1);
			out.references.push(tValue);
			return tValue;
		}

		parseType(tValue);

		return tValue;
	}

	static function parseType(tValue: TValue): Void {
		tValue.value = switch (tValue.type) {
			case "Bool": parseBool(tValue.valueStr);
			case "Color": parseColor(tValue.valueStr);
			case "Float": parseFloat(tValue.valueStr);
			case "Int": parseInt(tValue.valueStr);
			case "String", "Asset": parseString(tValue.valueStr);
			default:
				throw "Internal Error!";
		}

		if (tValue.type == "Asset") {
			out.assetNames.add(tValue.value);
			tValue.type = "String";
		}
	}

	static function parseBool(valueStr: String): Bool {
		if (valueStr.toLowerCase() == "true") return true;
		else if (valueStr.toLowerCase() == "false") return false;
		else throw 'Invalid value for type Bool: "$valueStr"!';
	}

	/**
	 * Parses a color in the format #rrggbbaa or #RRGGBBAA
	 */
	static function parseColor(valueStr: String): Color {
		if (regColor.match(valueStr)) {
			var r = Std.parseInt("0x" + regColor.matched(1));
			var g = Std.parseInt("0x" + regColor.matched(2));
			var b = Std.parseInt("0x" + regColor.matched(3));
			var a = 255;
			if (regColor.matched(4) != "") {
				a = Std.parseInt("0x" + regColor.matched(4));
			}

			return Color.fromBytes(r, g, b, a);

		} else {
			throw 'Invalid value for type Color: "$valueStr"!';
		}
	}

	static function parseFloat(valueStr: String): kha.FastFloat {
		var value = Std.parseFloat(valueStr);
		if (Math.isNaN(value)) {
			throw 'Invalid value for type Float: "$valueStr"!';
		}
		return value;
	}

	static function parseInt(valueStr: String): Int {
		var value = Std.parseInt(valueStr);
		if (value == null) {
			throw 'Invalid value for type Int: "$valueStr"!';
		}
		return value;
	}

	static function parseString(valueStr: String): String {
		if (!valueStr.startsWith("\"") || !valueStr.endsWith("\"")) {
			throw 'String must have double quotes around them! String: $valueStr';
		}

		// Remove quotes
		valueStr = valueStr.substr(1, valueStr.length - 2);
		valueStr = valueStr.unescape();
		return valueStr;
	}

	static function resolveExtensions(selector: TSelector): Void {
		if (selector.resolvedExtensions) return;

		// No extension
		if (selector.extending == null) {
			resolveStates(selector);
			return;
		}

		var extending = out.selectors.get(selector.extending);
		if (extending == null) {
			throw 'Selector ${selector.name} extends ${selector.extending} but extension does not exist!';
		}

		// trace('Resolve Exts: ${selector.name} > ${extending.name}');

		selector.map = mergeSelectorsResolved(selector, extending);
	}

	/**
	 * Create states from extended selector if they aren't defined yet.
	 * @param selector
	 */
	static function createRequiredStates(selector: TSelector): Void {
		// Only use default state selectors, no duplicate execution needed
		if (selector.extending == null || selector.state != "!default" || selector.hasAllStates) return;

		var extending = out.selectors[selector.extending];
		if (!extending.hasAllStates) {
			createRequiredStates(extending);
		}

		for (state in out.selectorStates[extending.pureName]) {
			if (!out.selectorStates[selector.pureName].has(state)) {
				out.selectorStates[selector.pureName].push(state);

				var tSelector: TSelector = {
					name: selector.pureName + state,
					map: new Map<String, Node>(),
					resolvedExtensions: false,
					hasAllStates: true,
					pureName: selector.pureName,
					state: state,
					extending: extending.pureName + state
				};
				out.selectors.set(tSelector.name, tSelector);
			}
			else {
				out.selectors[selector.pureName + state].hasAllStates = true;
			}
		}
	}

	static function resolveStates(selector: TSelector): Void {
		if (selector.resolvedExtensions || selector.state == "!default") return;

		var pureName = selector.pureName;
		// This selector with default state
		var defaultSelector = out.selectors.get(pureName + "!default");
		if (defaultSelector == null) {
			throw 'Selector ${selector.name} is missing a default state!';
		}

		// Use this temporary map to first merge the extended same-state
		// and the same-selector default state maps together. If both would
		// be merged directly onto this selector's map, the values from the
		// extended same-state map would override the same-selector default
		// state values because the first merged values would be interpreted
		// as if they were already on the main selector map due to the merge...
		var extendingMap: Null<Map<String, Node>> = null;

		// First, inherit from the extended selector with the same state
		if (defaultSelector.extending != null) {
			var stateName = selector.state.substr(1);
			var extendingSameStateName = defaultSelector.extending.split("!")[0] + "!" + stateName;
			var extendingSameState = out.selectors.get(extendingSameStateName);

			if (extendingSameState != null) {
				// trace('Resolve States: ${selector.name} > ${extendingSameState.name}');
				if (!defaultSelector.resolvedExtensions) {
					resolveExtensions(defaultSelector);
					resolveStates(defaultSelector);
				}
				extendingMap = mergeSelectorsResolved(defaultSelector, extendingSameState);
			}
		}
		// Then, extend from the default state of this selector
		// trace('Resolve States: ${selector.name} > ${defaultSelector.name}');
		if (extendingMap == null) {
			if (!defaultSelector.resolvedExtensions) {
				resolveExtensions(defaultSelector);
				resolveStates(defaultSelector);
			}
			selector.map = mergeMaps(defaultSelector.map, selector.map);
		}
		else {
			selector.map = mergeMaps(extendingMap, selector.map);
		}

		selector.resolvedExtensions = true;
	}

	static function resolveReferences(tValue: TValue): Void {
		var path = tValue.reference.split(".");

		var referencedSelector = out.selectors.get(path[0]);
		if (referencedSelector == null) {
			referencedSelector = out.selectors.get(path[0] + "!default");
		}
		if (referencedSelector == null) {
			throw 'Referenced selector "${path[0] + "!default"}" does not exist!';
		}
		path.shift();
		var referencedNode = traverseByPath(referencedSelector.map, path);

		switch (referencedNode) {
			case EValue(tReferencedValue):
				// Does not terminate for cyclic references!
				if (tReferencedValue.reference != null) {
					resolveReferences(tReferencedValue);
				}

				tValue.valueStr = tReferencedValue.valueStr;

			case EGroup(_):
				throw "Reference to group currently not allowed!";

			default:
				throw "Internal error! referencedNode: " + referencedNode;
			}

		// Mark reference as resolved
		tValue.reference = null;

		parseType(tValue);
	}

	/**
	 * Merges the base selector on top of the extending selector (this modifies
	 * the base selector's map in place). If the extending selector is not
	 * resolved yet, resolve it first.
	 */
	static function mergeSelectorsResolved(base: TSelector, extending: TSelector): Map<String, Node> {
		// Resolve all extensions of the extension first (recursively)
		if (!extending.resolvedExtensions) {
			resolveExtensions(extending);
			resolveStates(extending);
		}

		return mergeMaps(extending.map, base.map);
	}

	/**
	 * Creates a deep copy of a map (the given map must not contain values of
	 * types other than primitive types or maps).
	 *
	 * @param setInherited If `true`, set all `EValue` entries in the cloned map
	 * 		to `inherited`. If `false`, keep the `inherited` value as it was.
	 */
	static function cloneMap(map: Map<String, Node>, setInherited: Bool): Map<String, Node> {
		final copiedMap = new Map<String, Node>();

		for (key => node in map) {
			switch node {
				case EValue(tValue):
					final copiedValue = Reflect.copy(tValue);
					if (setInherited) copiedValue.inherited = true;
					node = EValue(copiedValue);

				case EGroup(tGroup):
					final newTGroup = Reflect.copy(tGroup);
					newTGroup.map = cloneMap(newTGroup.map, setInherited);
					node = EGroup(newTGroup);

				case ESelector(tSelector):
					final newTSelector = Reflect.copy(tSelector);
					newTSelector.map = cloneMap(newTSelector.map, setInherited);
					node = ESelector(newTSelector);

				case EType(type):
					node = EType(type);
			}
			copiedMap.set(key, node);
		}
		return copiedMap;
	}

	/**
	 * Merges/Adds `mapAdd` onto `mapBase` (without changing those maps) and
	 * returns the resulting map. Usually used with `mapBase` being the extended
	 * map and `mapAdd` the actual selector's map.
	 */
	static function mergeMaps(mapBase: Map<String, Node>, mapAdd: Map<String, Node>): Map<String, Node> {
		mapBase = cloneMap(mapBase, true);

		for (key => valueAdd in mapAdd) {
			var valueBase = mapBase.get(key);

			switch valueAdd {
				case EValue(tValue):
					if (tValue.inherited) continue;

					if (valueBase == null) {
						throw 'Could not find property "$key" in extension or sub-extensions!';
					}
					var copiedValue = Reflect.copy(tValue);
					copiedValue.inherited = false;
					mapBase.set(key, EValue(copiedValue));

				case EGroup(tGroup):
					if (valueBase == null) {
						if (tGroup.optional) {
							mapBase.set(key, EGroup(tGroup));
							continue;
						}
						else {
							throw 'Could not find group "$key" in extension or sub-extensions!';
						}
					}

					switch (valueBase) {
						case EGroup(tBaseGroup):
							tBaseGroup.map = mergeMaps(tBaseGroup.map, tGroup.map);

						default:
					}

				default:
			}
		}

		return mapBase;
	}

	static function getCurrentPath(): Array<String> {
		var path = new Array<String>();
		// Reverse the stack
		for (entry in parserState.pathStack) {
			path.insert(0, entry);
		}
		return path;
	}

	static function pathToString(?path: Array<String>): String {
		if (path == null) path = getCurrentPath();
		var buffer = new StringBuf();
		var first = true;

		for (entry in path) {
			if (!first) buffer.addChar(".".code);
			else first = false;

			buffer.add(entry);
		}

		return buffer.toString();
	}

	static function calculateIndentation(indentation: Int): Void {
		var lastIndentLevel = parserState.indentStack.first();

		// Not allowed to indent more than one level at once. It is also not
		// allowed to add indentation to subsequent lines of definitions.
		if (indentation > lastIndentLevel + 1
				|| (indentation > lastIndentLevel && parserState.lastLineType == Definition)) {
			throw "Syntax error: wrong indentation!";
		}

		if (indentation > lastIndentLevel) {
			parserState.indentStack.add(indentation);
		}

		// Go levels back
		else {
			while (indentation < parserState.indentStack.first()) {
				parserState.indentStack.pop();
			}
		}
	}

	static function unindent(indentLevel: Int, lastIndentLevel: Int) {
		while (indentLevel <= lastIndentLevel) {
			// Don't pop the last remaining level of indentation
			if (indentLevel != lastIndentLevel) {
				parserState.outputStack.pop();
			}
			parserState.pathStack.pop();
			indentLevel++;
		}
	}

	static function traverseByPath(map: StringMap<Node>, path: Array<String>): Node {
		var currentNode = map.get(path[0]);
		if (currentNode == null) {
			throw 'Referenced group "${path[0]}" does not exist!';
		}
		path.shift();

		for (entry in path) {
			switch (currentNode) {
				case EGroup(tGroup):
					currentNode = tGroup.map.get(entry);

				default:
			}

			if (currentNode == null) {
				throw 'Referenced group "$entry" does not exist!';
			}
		}

		return currentNode;
	}

	static function validateNoKeyword(name: String) {
		if (reservedKeywords.has(name)) {
			throw '"$name" is a reserved Haxe keyword!';
		}
	}

	static inline function registerSelectorState(pureSelectorName: String, state: String) {
		// state must include the "!"
		if (out.selectorStates.exists(pureSelectorName)) {
			out.selectorStates[pureSelectorName].push(state);
		}
		else {
			out.selectorStates[pureSelectorName] = [state];
		}
	}

	#if KOUI_DEBUG_THEME_PARSER
	static inline function debugLine(lastIndentLevel: Int, matchedGroup: String, matchedValue: String): Void {
		trace('Reading line:\nIndent: ${parserState.indentStack.first()}\nLast Indent:$lastIndentLevel
Group: $matchedGroup\nValue: $matchedValue\nPath: ${pathToString()}\noutStack: ${parserState.outputStack}');
	}
	#end
}

/**
 * Holds information about the current state of the parser
 */
typedef TParserState = {
	/** The current line the parser is in */
	var currentLine: Int;

	/** Whether the @rules line was found */
	var foundRules: Bool;

	/** Whether the parsed lines describe rules or properties */
	var visitingRules: Bool;

	/** Whether the parser is in the @globals section (section must not exist) */
	var visitingGlobals: Bool;

	/** @see https://docs.python.org/3/reference/lexical_analysis.html#indentation */
	var indentStack: GenericStack<Int>;

	/** The current output map that should be written to */
	var outputStack: GenericStack<Node>;

	/** The current path */
	var pathStack: GenericStack<String>;

	/** The type of the last read line */
	var lastLineType: LineType;

	/**
	 * True if the parser runs on another theme file that should be appended to
	 * the already parsed theme file(s).
	 */
	var consecutiveRun: Bool;
}

typedef TOutput = {
	var rules(default, null): Map<String, Node>;
	var props(default, null): Map<String, Dynamic>;
	var selectors(default, null): Map<String, TSelector>;
	var references(default, null): Array<TValue>;
	/** All states for a given selector */
	var selectorStates: Map<String, Array<String>>;
	/** Names of assets to load when Koui initializes */
	var assetNames: Set<String>;
}

typedef TSelector = {
	/** pureName + state, used as ID */
	var name: String;
	var map: Map<String, Node>;
	var resolvedExtensions: Bool;
	/**
	 * If true, this selector already has all the states of the selector it
	 * extends.
	*/
	var hasAllStates: Bool;
	var pureName: String;
	var state: String;
	@:optional var extending: String;
}

typedef TValue = {
	var path: String;
	var type: String;
	var valueStr: String;
	var inherited: Bool;
	@:optional var reference: String;
	@:optional var value: Dynamic;
}

typedef TGroup = {
	var path: String;
	var optional: Bool;
	var map: Map<String, Node>;
}

enum Node {
	EValue(tValue: TValue);
	EGroup(tGroup: TGroup);
	ESelector(tSelector: TSelector);
	EType(type: String);
}

enum abstract LineType(Int) {
	var Selector;
	var Group;
	var Definition;
	var None;
}
