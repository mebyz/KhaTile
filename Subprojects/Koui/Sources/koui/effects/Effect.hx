package koui.effects;

import haxe.macro.Expr;
import haxe.rtti.Meta;
import haxe.rtti.Rtti;

/**
 * The base class of all effects.
 */
@:build(koui.utils.EffectUtil.registerEffects())
class Effect {
	/**
	 * This method is called automatically by `initAll()` called in Koui's
	 * initialization phase and can be overriden by effects. Please note that
	 * `init()` is static.
	 */
	private static inline function init() {}


	/**
	 * Initializes all subclasses of this class that override the `init()`
	 * method.
	 */
	@:allow(koui.Koui)
	private static function initAll() {
		// The build macro `EffectUtil.registerEffects()` stores all subclasses
		// of `Effect` in a metadata called "subclasses".
		for (subclassName in Meta.getType(Effect).subclasses) {
			var subclass = Type.resolveClass(subclassName);

			// Reflect.field doesn't work with overrides so this workaround is
			// required
			var initField = Reflect.field(subclass, "init");
			var tmpClass = subclass;
			while (initField == null && Type.getSuperClass(tmpClass) != null) {
				tmpClass = Type.getSuperClass(tmpClass);
				initField = Reflect.field(subclass, "init");
			}

			if (initField != null) {
				Reflect.callMethod(subclass, initField, []);
			}
		}
	}
}
