package;

import kha.WindowOptions;
import kha.Image;
import kha.Scheduler;
import kha.System;
import koui.Koui;
import koui.elements.*;
import io.colyseus.Client;
import io.colyseus.Room;

class Main {

	public static function main() {

		
		var client = new Client('ws://localhost:2567');
		#if js
		var canvas = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
		canvas.width = js.Browser.window.innerWidth;
		canvas.height = js.Browser.window.innerHeight;      
		#end
		System.start({title: "PlaneInstance"}, function(_) {

			Koui.init(() -> {
                var button = new Button("Click me!");
                button.setPosition(10, 10);
            
               

                Koui.add(button);

				var game = new PlaneInstance();

				Scheduler.addTimeTask(function() {
					game.update();
				}, 0, 1 / 50);
				System.notifyOnFrames(function(f) {
					game.render(f);
				});
            });

				
		});
	}
}
