package koui.theme;

/**
 * This class contains all data related to the element's style.
 *
 * - To learn more about how to create custom themes, please take a look at
 *   [Wiki: Themes](https://gitlab.com/koui/Koui/-/wikis/Documentation/Themes).
 *
 * - To get an overview of what the different variables do in detail, please refer to
 *   [Wiki: Elements](https://gitlab.com/Koui/koui/-/wikis/Documentation/Elements).
 */
@:build(koui.theme.ThemeUtil.buildStyle())
class Style {
	/**
	 * All available styles. Use the `tID` of elements as the key.
	 * @see [`getStyle()`](#getStyle)
	 */
	static var styles = new Map<String, Style>();

	/** Names of assets that are required by the theme. */
	public static var requiredAssets(default, null): Array<String>;

	@:keep
	inline function new() {}

	/**
	 * Initialize the values of all style objects. The content of this method
	 * is generated by the `ThemeUtil.buildStyle()` macro.
	 */
	@:keep
	@:allow(koui.Koui)
	static function init() {}

	/**
	 * Override a property from the style.
	 *
	 * @see `Style.withOverride`
	 *
	 * @param styleGroup The group, e.g. `style.color`
	 * @param overrideProp The name of the property inside that group
	 * @param newValue The new value
	 * @return The old, overridden value (to undo the override later)
	 */
	public static inline function makeOverride(styleGroup: Dynamic, overrideProp: String, newValue: Dynamic): Dynamic {
		var oldValue = Reflect.field(styleGroup, overrideProp);
		Reflect.setField(styleGroup, overrideProp, newValue);
		return oldValue;
	}

	/**
	 * Python-like context manager to execute the given function while
	 * overriding a property from the style. After the execution, the property is reset to
	 * its state before calling this function.
	 *
	 * @see `Style.makeOverride`
	 *
	 * @param styleGroup The group, e.g. `style.color`
	 * @param overrideProp The name of the property inside that group
	 * @param newValue The new value
	 * @param action Function to execute while the override is active
	 */
	public static inline function withOverride(styleGroup: Dynamic, overrideProp: String, newValue: Dynamic, action: Void->Void) {
		var oldPropVal: Dynamic = makeOverride(styleGroup, overrideProp, newValue);
		action();
		makeOverride(styleGroup, overrideProp, oldPropVal);
	}

	/**
	 * Return the style object for the given `tID`, or `null` if it does not
	 * exist.
	 */
	public static inline function getStyle(tID: String, state: String = "default"): Null<Style> {
		// "!" is replaced with "_" in theme generation
		return styles[tID + "_" + state];
	}

}