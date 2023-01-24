package koui.utils;

import haxe.Exception;

/**
 * Logging utility.
 */
class Log {
	/**
	 * Throws an exception with the message `"[Koui Error] <message>"`.
	 */
	public static inline function error(message: String) {
		throw new Exception('[Koui Error] $message');
	}

	/**
	 * Outputs a warning in the format `"[Koui Warning] <message>`.
	 */
	public static inline function warn(message: String) {
		trace('[Koui Warning] $message');
	}

	#if macro
	public static inline function out(message: String) {
		Sys.println("[Koui] " + message);
	}
	#end
}
