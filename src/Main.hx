package;

import kha.Scheduler;
import kha.System;

class Main {
	public static function main() {
	#if js
    var canvas = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
    canvas.width = js.Browser.window.innerWidth;
    canvas.height = js.Browser.window.innerHeight;      
    #end

		System.init("PlaneInstance", 1024, 728, init);
	}

	static function init() {
		var game = new PlaneInstance();
		System.notifyOnRender(game.render);
	}
}
