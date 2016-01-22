package;

import kha.Scheduler;
import kha.System;

class Main {
	public static function main() {
		System.init("PlaneInstance", 640, 480, init);
	}

	static function init() {
		var game = new PlaneInstance();
		System.notifyOnRender(game.render);
	}
}
