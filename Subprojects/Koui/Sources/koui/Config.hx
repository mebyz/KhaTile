package koui;

/**
 * Collection of global variables that define how Koui behaves. Koui only reads
 * from those variables and does not change their values.
 */
class Config {
	/**
	 * The amount of pixels that are scrolled if the mouse wheel is rotated.
	 *
	 * @see `koui.elements.layouts.ScrollPane`
	 */
	public static var scrollSensitivity = 50;

	/**
	 * The duration after which a held down key triggers again for the second
	 * time.
	 *
	 * @see `koui.events.EventHandler`
	 */
	public static var keyRepeatDelay = 0.5;
	/**
	 * The duration after which a held down key triggers again for consecutive
	 * times.
	 *
	 * @see `koui.events.EventHandler`
	 */
	public static var keyRepeatPeriod = 0.03;

	/**
	 * The maximum length of the text in new `TextInput` elements.
	 *
	 * @see `koui.elements.TextInput`
	 */
	public static var textInputMaxLength = 1024;

	#if KOUI_DEBUG_LAYOUT
	public static var DBG_COLOR_ANCHORPANE: kha.Color = 0xffff00ff;
	public static var DBG_COLOR_GRIDLAYOUT: kha.Color = 0xffffff00;
	public static var DBG_COLOR_EXPANDER: kha.Color = 0xff00ffff;
	public static var DBG_COLOR_SCROLLPANE: kha.Color = 0xffff0000;
	#end
}
