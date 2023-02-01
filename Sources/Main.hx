package;

import kha.Image;
import kha.Scheduler;
import kha.System;
import koui.Koui;
import koui.elements.*;

class Main {

	public static function main() {
		System.start({title: "PlaneInstance", width: 1800, height: 1600}, function(_) {

			Koui.init(() -> {
                var button = new Button("Click me!");
                button.setPosition(400, 180);
            
               

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
