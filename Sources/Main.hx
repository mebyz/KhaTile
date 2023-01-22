package;

import kha.Scheduler;
import kha.System;

class Main {
	public static function main() {
		System.start({title: "PlaneInstance", width: 1800, height: 1600}, function(_) {
			var game = new PlaneInstance();

			Scheduler.addTimeTask(function() {
				game.update();
			}, 0, 1 / 50);
			System.notifyOnFrames(function(f) {
				game.render(f);
			});
		});
	}
}
