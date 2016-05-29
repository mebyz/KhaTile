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

	 	
		System.init({title:"PlaneInstance", width:1024, height:728}, init);
	}
	
	public static function init() {
		var game = new PlaneInstance();
		System.notifyOnRender(game.render);		
		Scheduler.addTimeTask(game.update, 0, 1 / 60);
	}
}
