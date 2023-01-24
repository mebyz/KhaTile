package koui.utils;

using StringTools;

/**
 * Helper class to aid working with different unicode character sets.
 *
 * @see Some help with the terminology on this page: [StackOverflow](https://stackoverflow.com/a/27331885/9985959)
 */
class FontUtil {
	/**
	 * Glyphs that are always loaded (Basic Latin, Latin-1 Supplement,
	 * Latin Extended-A).
	 */
	public static final BASE_GLYPHS = [for (i in 32...383) i];

	/**
	 * Glyph codepoints for additionally supported locales.
	 *
	 * @see https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
	 */
	public static final localeDefaultGlyphs: Map<String, Array<Int>> = [
		"el" => [for (i in 0x0370...0x03ff) i], // Greek
		"ru" => [for (i in 1024...1119) i] // Cyrillic
	];

	static var additionalGlyphs: Set<Int> = new Set();
	static var additionalLocales: Set<String> = new Set();

	/**
	 * Additionally load glyphs from the given locale from
	 * `FontUtil.localeDefaultGlyphs`.
	 *
	 * @param locale The locale code according to ISO 639-1
	 */
	public static function loadGlyphsFromLocale(locale: String) {
		if (!localeDefaultGlyphs.exists(locale)) {
			Log.warn('No default glyphs for locale $locale found!');
			return;
		}

		additionalLocales.add(locale);
		setKhaGlyphs();
	}

	/**
	 * Additionally load glyphs from all unicode character codes given in
	 * `codepoints`.
	 */
	public static inline function loadGlyphsFromCodepoints(codepoints: Array<Int>) {
		for (codepoint in codepoints) {
			additionalGlyphs.add(codepoint);
		}
		setKhaGlyphs();
	}

	/**
	 * Additionally load glyphs from all characters in the given string.
	 */
	public static inline function loadGlyphsFromString(string: String) {
		for (i in 0...string.length) {
			additionalGlyphs.add(string.fastCodeAt(i));
		}
		setKhaGlyphs();
	}

	public static inline function loadGlyphsFromStringOptional(string: String) {
		#if !(KOUI_MANUAL_GLYPH_LOAD)
			loadGlyphsFromString(string);
		#end
	}

	/**
	 * Unload glyphs from the given locale from `FontUtil.localeDefaultGlyphs`.
	 * Glyphs that are loaded in another locale are not unloaded.
	 *
	 * @param locale The locale code according to ISO 639-1
	 *
	 * @see `loadGlyphsFromLocale`
	 */
	public static inline function unloadGlyphsFromLocale(locale: String) {
		additionalLocales.remove(locale);
		setKhaGlyphs();
	}

	/**
	 * Unload glyphs from all unicode character codes given in `codepoints`.
	 *
	 * @see `loadGlyphsFromCodepoints`
	 */
	public static inline function unloadGlyphsFromCodepoints(codepoints: Array<Int>) {
		for (codepoint in codepoints) {
			additionalGlyphs.remove(codepoint);
		}
		setKhaGlyphs();
	}

	/**
	 * Unload glyphs from all characters in the given string.
	 *
	 * @see `loadGlyphsFromString`
	 */
	public static inline function unloadGlyphsFromString(string: String) {
		for (i in 0...string.length) {
			additionalGlyphs.remove(string.fastCodeAt(i));
		}
		setKhaGlyphs();
	}

	/**
	 * Return an array with all ISO 639-1 locale codes from which glyphs are
	 * loaded in addition to `FontUtil.BASE_GLYPHS`.
	 */
	public static inline function getAdditionalLocales(): Array<String> {
		return additionalLocales.toArray();
	}

	/**
	 * Return a new array where duplicate entries from an already sorted integer
	 * array are removed.
	 */
	public static function removeDuplicatesFromSortedIArray(array: Array<Int>): Array<Int> {
		if (array.length == 0 || array.length == 1) {
			return array;
		}

		var outArray = new Array<Int>();
		// Must be initialized, Haxe compiler shenaniganss
		var lastEntry: Null<Int> = null;
		for (i in 0...array.length) {
			if (i != 0 && array[i] == lastEntry) {
				continue;
			}
			lastEntry = array[i];
			outArray.push(lastEntry);
		}

		return outArray;
	}

	static function setKhaGlyphs() {
		var allGlyphs = BASE_GLYPHS.copy();

		for (locale in additionalLocales) {
			allGlyphs = allGlyphs.concat(localeDefaultGlyphs[locale]);
		}
		allGlyphs = allGlyphs.concat(additionalGlyphs.toArray());

		// Kha's font glyphs must be sorted and unique
		allGlyphs.sort(Reflect.compare);
		kha.graphics2.Graphics.fontGlyphs = removeDuplicatesFromSortedIArray(allGlyphs);
	}
}
