package koui.utils;

import koui.elements.layouts.AnchorPane;
import koui.events.EventHandler;

/**
 * An utility to create different scenes or screens for different UI layouts,
 * for example a main menu and a option menu.
 *
 * Do not use `Koui.add()` in scenes! It will work but it ignores the current
 * scene.
 *
 * Internally, a scene is just a `AnchorPane` that is only visible if the scene
 * is active. Only one scene can be active at once.
 *
 * @see [Wiki: Documentation/Layouts](https://gitlab.com/koui/Koui/-/wikis/Documentation/Layouts#scenes)
 */
class SceneManager {
	static var scenes: Map<String, AnchorPane> = new Map();

	/**
	 * The anchor pane if the currently active scene.
	 */
	public static var activeScene(default, null): AnchorPane = null;

	/**
	 * Adds a scene. For setup, please use the `add()` function of the
	 * `AnchorPane` parameter of the `onSetup` callback.
	 *
	 * @param name The name of the new scene for later reference
	 * @param onSetup A callback that creates the UI for the scene
	 */
	public static function addScene(name: String, onSetup: AnchorPane->Void) {
		var scenePane = new AnchorPane(0, 0, kha.Window.get(0).width, kha.Window.get(0).height);

		scenes.set(name, scenePane);

		if (activeScene == null) {
			activeScene = scenePane;
		}
		else {
			scenePane.visible = false;
		}

		Koui.add(scenePane);
		onSetup(scenePane);
	}

	/**
	 * Sets the current scene by its name.
	 */
	@:access(koui.events.EventHandler)
	public static function setScene(name: String) {
		var newScene = scenes.get(name);
		if (newScene != null) {

			if (activeScene != null) {
				activeScene.visible = false;
			}

			activeScene = newScene;
			activeScene.visible = true;

			// Check mouse hover to ensure that the element under the cursor is
			// un-hovered
			EventHandler.checkMouseHover();
		}
		else {
			trace('Warning: Scene $name does not exist!');
		}
	}
}
