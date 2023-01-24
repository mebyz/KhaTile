package utils;

import utest.Assert;

import koui.utils.FontUtil;
import koui.utils.Set;

using StringTools;

@:access(koui.utils.FontUtil)
class TestFontUtil extends utest.Test {
	function setup() {
		FontUtil.additionalGlyphs = new Set();
		FontUtil.additionalLocales = new Set();
	}

	function teardown() {}

	function testLoadGlyphsFromLocale_EL() {
		var alphabet = "ΑαΒβΓγΔδΕεΖζΗηΘθΙιΚκΛλΜμΝνΞξΟοΠπΡρΣσςΤτΥυΦφΧχΨψΩω";
		FontUtil.loadGlyphsFromLocale("el");

		for (i in 0...alphabet.length) {
			Assert.contains(alphabet.fastCodeAt(i), kha.graphics2.Graphics.fontGlyphs);
		}
	}

	function testLoadGlyphsFromLocale_RU() {
		var alphabet = "АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя";
		FontUtil.loadGlyphsFromLocale("ru");

		for (i in 0...alphabet.length) {
			Assert.contains(alphabet.fastCodeAt(i), kha.graphics2.Graphics.fontGlyphs);
		}
	}

	function testLoadGlyphsFromString() {
		var alphabet = "ΑαΒβΓγΔδΕεΖζΗηΘθΙιΚκΛλΜμΝνΞξΟοΠπΡρΣσςΤτΥυΦφΧχΨψΩω";
		FontUtil.loadGlyphsFromString(alphabet);

		for (i in 0...alphabet.length) {
			Assert.contains(alphabet.fastCodeAt(i), kha.graphics2.Graphics.fontGlyphs);
		}
	}

	function testLoadGlyphsFromCodepoints() {
		var alphabet = "ΑαΒβΓγΔδΕεΖζΗηΘθΙιΚκΛλΜμΝνΞξΟοΠπΡρΣσςΤτΥυΦφΧχΨψΩω";

		var codepoints = new Array<Int>();
		for (i in 0...alphabet.length) {
			codepoints.push(alphabet.fastCodeAt(i));
		}

		FontUtil.loadGlyphsFromCodepoints(codepoints);

		for (codepoint in codepoints) {
			Assert.contains(codepoint, kha.graphics2.Graphics.fontGlyphs);
		}
	}

	function testUnloadGlyphsFromLocale() {
		FontUtil.loadGlyphsFromLocale("el");
		FontUtil.unloadGlyphsFromLocale("el");

		// Definitely not included in `FontUtil.BASE_GLYPHS`
		var someGreekChars = "ΦφΧχΨψΩω";
		for (i in 0...someGreekChars.length) {
			Assert.notContains(someGreekChars.fastCodeAt(i), kha.graphics2.Graphics.fontGlyphs);
		}
	}

	function testUnloadGlyphsFromCodepoints() {
		var someGreekChars = "ΦφΧχΨψΩω";

		var codepoints = new Array<Int>();
		for (i in 0...someGreekChars.length) {
			codepoints.push(someGreekChars.fastCodeAt(i));
		}

		FontUtil.loadGlyphsFromCodepoints(codepoints);
		FontUtil.unloadGlyphsFromCodepoints(codepoints);

		for (i in 0...someGreekChars.length) {
			Assert.notContains(someGreekChars.fastCodeAt(i), kha.graphics2.Graphics.fontGlyphs);
		}
	}

	function testUnloadGlyphsFromString() {
		var someGreekChars = "ΦφΧχΨψΩω";

		FontUtil.loadGlyphsFromString(someGreekChars);
		FontUtil.unloadGlyphsFromString(someGreekChars);

		for (i in 0...someGreekChars.length) {
			Assert.notContains(someGreekChars.fastCodeAt(i), kha.graphics2.Graphics.fontGlyphs);
		}
	}

	function testRemoveDuplicatesFromSortedIArray() {
		var array: Array<Int> = [-123, -123, 2, 2, 2, 3, 3, 70, 123];

		array = FontUtil.removeDuplicatesFromSortedIArray(array);

		Assert.same(array, [-123, 2, 3, 70, 123]);

		// Don't do anything for arrays with the length 0 or 1
		array = [];
		var array2 = FontUtil.removeDuplicatesFromSortedIArray(array);
		Assert.equals(array, array2);

		array = [1];
		array2 = FontUtil.removeDuplicatesFromSortedIArray(array);
		Assert.equals(array, array2);
	}

	function testGetAdditionalLocales() {
		FontUtil.loadGlyphsFromLocale("el");
		FontUtil.loadGlyphsFromLocale("ru");
		Assert.same(FontUtil.getAdditionalLocales(), ["el", "ru"]);
	}
}
