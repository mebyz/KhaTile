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

	 	
		System.start({title:"PlaneInstance", width:1800, height:1600},  function (_) {
			
			var game = new PlaneInstance();

            Scheduler.addTimeTask(function () { game.update(); }, 0, 1 / 30);
            System.notifyOnFrames(function (f) { game.render(f); });   

    	});
	}
	
}
