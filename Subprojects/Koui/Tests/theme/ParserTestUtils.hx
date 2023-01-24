package theme;

import haxe.ds.Map;

import koui.theme.parser.ThemeParser;

@:access(koui.theme.parser.ThemeParser)
class ParserTestUtils {
	public static function newSelector(name: String, state: String, resolved: Bool, extending: Null<String>): TSelector {
		var selector: TSelector = {
			name: name + state,
			map: new Map<String, Node>(),
			resolvedExtensions: resolved,
			pureName: name,
			state: state,
			extending: extending,
			hasAllStates: true
		};
		ThemeParser.out.selectors.set(selector.name, selector);
		ThemeParser.registerSelectorState(selector.pureName, state);

		return selector;
	}

	// function newSelector(name: String, state: String, resolved: Bool, extending: Null<String>) {
	// 	var selector: TSelector = {
	// 		name: name + state,
	// 		map: new Map<String, Node>(),
	// 		resolvedExtensions: resolved,
	// 		pureName: name,
	// 		state: state,
	// 		extending: extending
	// 	};
	// 	ThemeParser.out.selectors.set(selector.name, selector);
	// 	return selector;
	// }
}
