package koui.utils;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
#end

/**
 * Provides utility functions and macros for the `Effect` class.
 */
class EffectUtil {
	#if macro
	/**
	 * Register all effects, used by the `Effect` class only. Registration is
	 * required so that Koui can call the init()-method of all effects.
	 *
	 * @return Array<Field> The list of class fields
	 */
	static macro function registerEffects(): Array<Field> {
		Context.onGenerate(function getAllTypes(allTypes) {
			var subTypes = [];
			var baseClass = Context.getType("koui.effects.Effect").getClass();

			// Iterate through _every_ compiled type
			for (type in allTypes) {
				switch type {
					case TInst(_.get() => classType, _):
						if (classType.isInterface) {
							continue;
						}

						if (isSubclassOf(classType, "koui.effects", "Effect")) {
							subTypes.push(Context.makeExpr(classType.pack.join(".") + "." + classType.name, classType.pos));
						}

					default:
				}
			}

			baseClass.meta.add("subclasses", subTypes, baseClass.pos);
		});

		return Context.getBuildFields();
	}

	/**
	 * Return whether the given `subClass` is a subclass of `baseclassName` in
	 * the module `baseclassModule`.
	 *
	 * @param subClass
	 * @param baseclassModule
	 * @param baseclassName
	 * @return Bool
	 */
	static function isSubclassOf(subClass: ClassType, baseclassModule: String, baseclassName: String): Bool {
		var tmp = subClass;

		while (tmp.superClass != null) {
			tmp = tmp.superClass.t.get();

			if (tmp.name == baseclassName || tmp.module == baseclassModule) {
				return true;
			}
		}
		return false;
	}
	#end
}
