package;

import utest.Runner;
import utest.ui.Report;

class Main {
	static function main() {
		// Required for runner.run(). Don't know exactly why... It looks like
		// you need it because runner.run() uses haxe.Timer() and creating
		// a new kha window with kha.System.start() does not work because of the
		// node target, so it needs to be initialized manually.
		kha.Scheduler.init();

		kha.Assets.loadEverything(() -> {
			@:privateAccess koui.theme.Style.init();

			var runner = new Runner();

			registerElementsCases(runner);
			registerUtilCases(runner);
			registerThemeCases(runner);

			Report.create(runner);
			runner.run();
		});
	}

	static inline function registerElementsCases(runner: Runner) {
		runner.addCase(new elements.TestNumberInput());
		runner.addCase(new elements.TestSlider());
		runner.addCase(new elements.TestTextInput());

		runner.addCase(new elements.layouts.TestAnchorPane());
	}

	static function registerUtilCases(runner: Runner) {
		runner.addCase(new utils.TestStringUtil());
		runner.addCase(new utils.TestFontUtil());
	}

	static inline function registerThemeCases(runner: Runner) {
		runner.addCase(new theme.TestThemeParser());
	}
}
