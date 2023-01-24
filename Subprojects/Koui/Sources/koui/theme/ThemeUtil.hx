package koui.theme;

#if macro
import haxe.ds.StringMap;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.ObjectField;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
import haxe.macro.Compiler;
import sys.io.FileInput;
#end

import koui.utils.Log;
import koui.utils.Set;
import koui.theme.parser.ThemeParser;

using StringTools;
using koui.utils.StringUtil;

/**
 * Utility for generating the theme based on theme definition file. It also
 * provides macro functions to improve the theme workflow.
 */
class ThemeUtil {
	#if macro
	/**
	 * Returns the build directory (relative to the current working directory)
	 * that contains the main file (e.g. `krom.js`) and the assets specified in
	 * `khafile.js`.
	 * @return String The build directory
	 */
	static function getBuildDir(): String {
		var buildDir = new Path(Compiler.getOutput()).dir;

		// Remove "-build"
		if (buildDir.endsWith("-build")) {
			buildDir = buildDir.substring(0, buildDir.length - 6);
		}

		return buildDir;
	}

	static function getAllThemeFileNames(): Array<String> {
		var files: Array<String> = new Array();

		var mainThemeName = Context.definedValue("KOUI_THEME");
		var useDefaultTheme = mainThemeName == null;
		mainThemeName = useDefaultTheme ? "theme.ksn" : mainThemeName;

		for (filename in sys.FileSystem.readDirectory(getBuildDir())) {
			if (filename.endsWith(".ksn")) {
				// Don't append theme.ksn if it isn't the main theme
				if (!useDefaultTheme && filename == "theme.ksn") {
					continue;
				}

				if (filename == mainThemeName) {
					// Move to the front
					files.insert(0, filename);
				}
				else {
					files.push(filename);
				}
			}
		}
		return files;
	}

	/**
	 * Opens the theme file and returns a `FileInput` handler.
	 */
	static function openThemeFile(themeFile: String): FileInput {
		var themePath = haxe.io.Path.join([getBuildDir(), themeFile]);
		try {
			return sys.io.File.read(themePath, false);
		} catch (error: String) {
			Log.error('$themeFile was not found!');
		}
	}

	/**
	 * Builds the theme data according to the theme definition file defined via
	 * the `KOUI_THEME` flag. If that flag does not exist, the default theme
	 * is used.
	 */
	static macro function buildStyle(): Array<Field> {
		var parserOutput: TOutput;

		var first = true;
		for (themeFile in getAllThemeFileNames()) {
			if (first) {
				parserOutput = ThemeParser.parseFile(openThemeFile(themeFile));
				first = false;
			} else {
				parserOutput = ThemeParser.parseFile(openThemeFile(themeFile), true);
			}
		}

		ThemeParser.resolveTheme();

		Log.out("Generating theme types");

		var fields = Context.getBuildFields();
		generateTypes(parserOutput.rules, fields);

		var initFuncField: Field;
		for (field in fields) {
			if (field.name == "init") {
				initFuncField = field;
				break;
			}
		};

		if (initFuncField == null) {
			throw "Theme class must have a static function called init()";
		}

		Log.out("Writing theme data");
		generateStyles(initFuncField, parserOutput.selectors, parserOutput.assetNames);

		return fields;
	}

	/**
	 * Generates the "first level" of types, that are all types used directly by
	 * the `Style` class.
	 *
	 * @param rules The rules map from the theme parser
	 * @param fields The fields array of the Style class
	 */
	static function generateTypes(rules: StringMap<Node>, fields: Array<Field>) {
		for (ruleName => ruleNode in rules) {
			switch (ruleNode) {
				case EGroup(tGroup):
					var complexType = createStyleTypedef(ruleName, ruleNode);

					#if KOUI_DEBUG_THEME_GENERATOR
					trace('Defining class var $ruleName with type ${"T" + ruleName.toTitleCase()}');
					#end

					fields.push({
						access: [APublic],
						name: ruleName,
						kind: FVar(tGroup.optional ? macro: Null<$complexType> : macro: $complexType, null),
						pos: Context.currentPos()
					});

				case EType(ruleType):
					ruleType = resolveRuleType(ruleType);

					#if KOUI_DEBUG_THEME_GENERATOR
					trace('Defining class var $ruleName with type $ruleType');
					#end

					var complexType = getComplexTypeFromString(ruleType);
					fields.push({
						access: [APublic],
						name: ruleName,
						kind: FVar(macro: $complexType, macro $v{getDefaultValue(ruleType)}),
						pos: Context.currentPos()
					});

				default:
			}
		}
	}

	/**
	 * Creates a typedef for a subgroup in the theme definition.
	 *
	 * @param ruleName The group name
	 * @param ruleNode The group `Node`
	 */
	static function createStyleTypedef(ruleName: String, ruleNode: Node): ComplexType {
		var tName = "T" + ruleName.toTitleCase();
		var tFields = new Array<Field>();

		var subRules: StringMap<Node>;
		switch (ruleNode) {
			case EGroup(tGroup):
				subRules = tGroup.map;

			default:
				throw 'Internal error: createStyleTypedef() was called with non-group Node: $ruleNode!';
		}

		for (subRuleName => subRuleNode in subRules) {
			switch (subRuleNode) {
				case EGroup(tGroup):
					#if KOUI_DEBUG_THEME_GENERATOR
					trace('SubRule $subRuleName, $subRuleNode');
					#end

					var complexType = createStyleTypedef(ruleName + "_" + subRuleName.toTitleCase(), subRules.get(subRuleName));

					#if KOUI_DEBUG_THEME_GENERATOR
					trace('Defining typedef var $subRuleName with type ${"T" + ruleName.toTitleCase()}');
					#end

					var metadata: Metadata;
					if (tGroup.optional) {
						metadata = [{name: ":optional", pos: Context.currentPos()}];
					}

					tFields.push({
						access: [APublic],
						name: subRuleName,
						meta: metadata,
						kind: FVar(macro: $complexType, null),
						pos: Context.currentPos()
					});

				case EType(ruleType):
					ruleType = resolveRuleType(ruleType);

					#if KOUI_DEBUG_THEME_GENERATOR
					trace('Defining typedef var $subRuleName with type $ruleType');
					#end

					var complexType = getComplexTypeFromString(ruleType);
					tFields.push({
						access: [APublic],
						name: subRuleName,
						kind: FVar(macro: $complexType, null),
						pos: Context.currentPos()
					});

				default:
			}
		}

		#if KOUI_DEBUG_THEME_GENERATOR
		trace('Defining typedef $tName');
		#end

		var definition: TypeDefinition = {
			pack: ["koui.theme.internal"],
			kind: TDAlias(TAnonymous(tFields)),
			name: tName,
			fields: tFields,
			pos: Context.currentPos()
		};

		Context.defineType(definition);
		return TAnonymous(tFields);
	}

	/**
	 * Fills the init() method of the `Style` class with the code required to
	 * initialize all variables with the data from the theme definition.
	 *
	 * @param initFuncField The class field of the init() method
	 * @param selectors The map of selectors returned by the theme parser
	 * @param assetNames The array of required assets as returned by the theme parser
	 */
	static function generateStyles(initFuncField: Field, selectors: StringMap<TSelector>, assetNames: Set<String>) {
		switch initFuncField.kind {
			case FFun(func):
				var exprDef = func.expr.expr;
				switch (exprDef) {
					case EBlock(expressions):

						for (tID => selector in selectors) {
							tID = tID.replace("!", "_"); // "!" is not allowed in variable names
							var styleVarName = "style_" + tID;

							expressions.push(macro var $styleVarName = new Style());
							expressions.push(macro Style.styles.set($v{tID}, $i{styleVarName}));

							generateStyleContent(selector.map, expressions, macro $i{styleVarName});
						}

						expressions.push(macro Style.requiredAssets = $v{assetNames.toArray()});

					default:
						throw Log.error('The init() function of the Style class must be a block, please put it in curly braces!');
				}
			default:
				throw "Internal error!";

		}
	}

	/**
	 * Generates the style data for a given node (might be a group or a
	 * selector) for the "first level", that are class level variables.
	 *
	 * @param nodesMap The map of the node from which to take the data
	 * @param expressions All generated expressions will be pushed to this array
	 * @param styleVar The identifier of the base variable the given node belongs to
	 */
	static function generateStyleContent(nodesMap: StringMap<Node>, expressions: Array<Expr>, styleVar: Expr): Array<Expr> {
		for (key => subNode in nodesMap) {
			switch subNode {
				case EGroup(tGroup):
					var expr: Expr = {expr: EObjectDecl(generateStyleTypedefs(tGroup.map)), pos: Context.currentPos()};
					expressions.push(macro $styleVar.$key = $expr);

				case EValue(tValue):
					if (tValue.type == "Color") {
						expressions.push(macro $styleVar.$key = kha.Color.fromValue($v{tValue.value}));
					}
					else {
						expressions.push(macro $styleVar.$key = $v{tValue.value});
					}

				default:
					throw "Internal error!";
			}
		}

		return expressions;
	}

	/**
	 * Generates the style data for a given node (might be a group or a
	 * selector) for all definition subgroups (typedefs).
	 *
	 * @param nodesMap The map of the node from which to take the data
	 */
	static function generateStyleTypedefs(nodesMap: StringMap<Node>): Array<ObjectField> {
		var expressions = new Array<ObjectField>();

		for (key => subNode in nodesMap) {
			switch (subNode) {
				case EGroup(tGroup):
					expressions.push({field: key, expr: {expr: EObjectDecl(generateStyleTypedefs(tGroup.map)), pos: Context.currentPos()}});

				case EValue(tValue):
					if (tValue.type == "Color") {
						expressions.push({field: key, expr: macro kha.Color.fromValue($v{tValue.value})});
					}
					else {
						expressions.push({field: key, expr: macro $v{tValue.value}});
					}

				default:
					throw "Internal error!";
			}
		}

		return expressions;
	}

	static inline function getComplexTypeFromString(typeName: String): ComplexType {
		return Context.toComplexType(Context.getType(typeName));
	}

	static function getDefaultValue(typeName: String): Dynamic {
		return switch (typeName) {
			case "Int": 0;
			case "Float": 0.0;
			case "Bool": false;
			case "String": "";
			case "kha.Color": kha.Color.fromBytes(0, 0, 0, 1);
			default: throw 'Internal error! Type $typeName not supported!';
		}
	}

	static inline function resolveRuleType(ruleType: String): String {
		return switch (ruleType) {
			case "Color": "kha.Color";
			case "Asset": "String";
			default: ruleType;
		};
	}

	/**
	 * Sets the element's initial `tID` property. Used internally only.
	 * @return Array<Field> The list of class fields
	 */
	static macro function buildSubElement(): Array<Field> {
		var localClass = Context.getLocalClass().get();
		var fields = Context.getBuildFields();

		var initStyleFunc = getFunction(localClass, fields, "initStyle");
		if (initStyleFunc == null) {
			initStyleFunc = {
				ret: null,
				expr: macro {},
				args: []
			};

			fields.push({
				access: [APrivate, AOverride],
				name: 'initStyle',
				kind: FFun(initStyleFunc),
				pos: Context.currentPos()
			});
		}
		var initStyleExpressions = getFunctionBlockExpressions(initStyleFunc);

		// Set the default theme ID for this class
		var tID = "_" + localClass.name.toLowerCase();
		initStyleExpressions.insert(0, macro this.initTID($v{tID}, $v{localClass.name}));

		return fields;
	}

	static function getFunction(localClass: ClassType, classFields: Array<Field>, functionName: String): Null<Function> {
		for (field in classFields) {
			if (field.name == functionName) {
				return getFieldFunction(localClass, field);
			}
		};
		return null;
	}

	static function getFieldFunction(localClass: ClassType, field: Field): Function {
		return switch (field.kind) {
			case FFun(func):
				func;
			default:
				Log.error('Class ${localClass.name}: "${field.name}" is not a function');
				return null;
		}
	}

	static function getConstructorField(localClass: ClassType, classFields: Array<Field>): Field {
		for (field in classFields) {
			if (field.name == "new") {
				return field;
			}
		};

		Log.error('${localClass.name} is missing a constructor!');
	}

	static function getConstructorFunc(localClass: ClassType, classFields: Array<Field>): Function {
		switch (getConstructorField(localClass, classFields).kind) {
			case FFun(func):
				return func;
			default:
				Log.error('Class ${localClass.name}: "new" must be a constructor field!');
		}
	}

	static function getConstructorBlockExpressions(localClass: ClassType, classFields: Array<Field>): Array<Expr> {
		var constructorFunc = getConstructorFunc(localClass, classFields);

		var exprDef = constructorFunc.expr.expr;
		switch (exprDef) {
			case EBlock(expressions):
				return expressions;
			default:
				Log.error('The construcor of ${localClass.name} must be a block, please put it in curly braces!');
		}
	}

	static function getFunctionBlockExpressions(func: Function): Array<Expr> {
		switch (func.expr.expr) {
			case EBlock(expressions):
				return expressions;
			default:
				return null;
		}
	}
	#end

	/**
	 * Macro to inject the code that will output the current font of the element
	 * that's calling this macro.
	 *
	 * It is important to first load all font assets before they can get
	 * accessed!
	 *
	 * ```haxe
	 * // In your code:
	 * g.font = ThemeUtil.getFont();
	 * // Compiles to:
	 * g.font = kha.Assets.fonts.get(style.font.family);
	 * ```
	 *
	 * **Important:** Use this macro on sub-classes of `Element` only, otherwise
	 * it will fail. Using it in static functions also does not work!
	 *
	 * @return The expression that is injected into the code
	 */
	public static macro function getFont(): Expr {
		return macro kha.Assets.fonts.get(style.font.family);
	}

	/**
		This macro is used internally by elements to ensure that required
		optional groups exist.

		If there is a definition like the following in the theme file:
		```txt
		?optionalGroup:
		 	value1: Int
		 	value2: Bool
		```

		and an element requires that group, it calls
		`ThemeUtil.requireOptGroups(["optionalGroup"]);`.
		For nested groups, write out the path like `group.subgroup`.

		If any of the groups does not exist for the current `tID`, an exception
		is thrown.

		This macro must not be called outside of `Element.onTIDChange()`,
		otherwise an exception is thrown.
	**/
	public static macro function requireOptGroups(groups: Array<String>): Expr {
		var callingClassName = Context.getLocalClass().get().name;

		if (Context.getLocalMethod() != "onTIDChange") {
			Context.error("[Koui Error] The \"requireGroups()\" macro is only allowed in \"onTIDChange()\"!", Context.currentPos());
		}

		var expressions = new Array<Expr>();

		for (group in groups) {
			var groupPath = group.split(".");

			// Construct identifiers in the form a.b.c etc.
			var start = groupPath[0];
			var expr = macro style.$start;
			groupPath.shift();

			for (entry in groupPath) {
				expr = macro $expr.$entry;
			}

			var errorExpr: Expr = MacroStringTools.formatString(
				callingClassName + ": Style must define properties for the \"" + group + "\" group! tID: $tID",
				Context.currentPos()
			);
			expressions.push(macro if ($expr == null) {
				Log.error(${errorExpr});
			});
		}

		return {expr: EBlock(expressions), pos: Context.currentPos()};
	}
}
