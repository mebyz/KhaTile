package koui.utils;

import StringBuf;

using StringTools;

/**
 * [Static extension](https://haxe.org/manual/lf-static-extension.html) with
 * useful string helper methods.
 *
 * ```haxe
 * // Put this after your imports and before the class declaration
 * using koui.util.StringUtil;
 *
 * // You can then use the methods from this class like this:
 * var reversed = "myString".reverse();
 * ```
 */
@:pure
class StringUtil {
	/**
	 * Gives back the reversed string it is applied on.
	 */
	public static function reverse(s: String): String {
		var sBuf = new StringBuf();
		// Iterate backwards
		for (i in -s.length + 1 ... 1) {
			sBuf.addChar(s.fastCodeAt(-i));
		}
		return sBuf.toString();
	}

	/**
	 * Converts the first character of the given string to uppercase. All other
	 * characters remain untouched.
	 */
	public static function toTitleCase(s: String): String {
		if (s == "") return s;
		return s.charAt(0).toUpperCase() + s.substr(1);
	}

	/**
	 * Unescapes a given string. The following characters are unescaped:
	 * ```txt
	 * \n -> Newline
	 * \r -> Carriage Return
	 * \t -> Tab
	 * \" -> "
	 * \\ -> \
	 * ```
	 */
	public static function unescape(s:String) {
		var sBuf = new StringBuf();

		var foundBackslash = false;
		for (i in 0...s.length) {
			if (foundBackslash) {
				var charCode = s.fastCodeAt(i);
				sBuf.addChar(switch (charCode) {
					case "\\".code: "\\".code;
					case "n".code: "\n".code;
					case "r".code: "\r".code;
					case "t".code: "\t".code;
					default:
						throw 'Wrong escape code: "\\${String.fromCharCode(charCode)}"';
				});

				foundBackslash = false;
			}
			else {
				if (s.fastCodeAt(i) == "\\".code) {
					foundBackslash = true;
				} else {
					sBuf.addChar(s.fastCodeAt(i));
				}
			}
		}

		return sBuf.toString();
	}

	/**
	 * Compares the given character against a list of characters that cannot be
	 * printed (ASCII control characters for example) and returns true if the
	 * character does not match those non-printable characters.
	 *
	 * If `newLineAllowed` is `true`, newline (`\n`) and carriage return (`\r`)
	 * characters will return `true`.
	 *
	 * @param char The character that should be compared
	 * @param newLineAllowed Whether `\n` and `\r` should return `true`
	 */
	public static function canPrintChar(char: String, newLineAllowed = false): Bool {
		// Use `!` and `||` instead of `&&` to jump out of the comparison if a
		// character matches. => Better performance.
		return !(
			(char == "\n" && !newLineAllowed)
			|| (char == "\r" && !newLineAllowed)
			// More ASCII control characters (occur when typing `Ctrl + A` for
			// example). See http://www.columbia.edu/kermit/ascii.html.
			|| char == "\000"
			|| char == "\001"
			|| char == "\002"
			|| char == "\003"
			|| char == "\004"
			|| char == "\005"
			|| char == "\006"
			|| char == "\007"
			|| char == "\010"
			|| char == "\011"
			|| char == "\012"
			|| char == "\013"
			|| char == "\014"
			|| char == "\015"
			|| char == "\016"
			|| char == "\017"
			|| char == "\020"
			|| char == "\021"
			|| char == "\022"
			|| char == "\023"
			|| char == "\024"
			|| char == "\025"
			|| char == "\026"
			|| char == "\027"
			|| char == "\030"
			|| char == "\031"
			|| char == "\032"
			|| char == "\033"
			|| char == "\034"
			|| char == "\035"
			|| char == "\036"
			|| char == "\037"
			|| char == "\177"
			);
	}
}
