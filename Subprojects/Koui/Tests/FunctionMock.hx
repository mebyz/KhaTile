package;

import haxe.Constraints.Function;

class FunctionMock {
	var object: Dynamic;
	var functionName: String;
	var originalFunc: Function;

	public function new(object: Dynamic, functionName: String, numArgs: Int = 0, ?returnValue: Dynamic) {
		this.object = object;
		this.functionName = functionName;
		this.originalFunc = Reflect.field(object, functionName);

		var mockedFunc = Reflect.makeVarArgs(function(args) {
			for (i in 0...numArgs) {
				args.push(null);
			}
			if (returnValue != null) {
				return returnValue;
			}
			return null;
		});

		Reflect.setField(object, functionName, mockedFunc);
	}

	public function unmock() {
		Reflect.setField(this.object, this.functionName, this.originalFunc);
	}
}
