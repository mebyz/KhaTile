package koui.utils;

import kha.input.Mouse.MouseCursor;

/**
 * This class handles all cursor-related tasks.
 */
@:allow(koui.events.EventHandler)
@:allow(koui.Koui)
class Cursor {
	static var mouse: kha.input.Mouse;
	static var mouseX = 0;
	static var mouseY = 0;

	static var type = MouseCursor.Default;
	static var systemCursorHidden(default, null) = false;

	static function init() {
		mouse = kha.input.Mouse.get();
	}

	/**
	 * Set the mouse position.
	 *
	 * @param x The x position
	 * @param y The y position
	 */
	public static function setPosition(x: Int, y: Int) {
		mouseX = x;
		mouseY = y;
	}

	/**
	 * Set the type of the mouse cursor.
	 *
	 * @param cursorType The cursor type
	 */
	public static function setCursor(cursorType: MouseCursor) {
		#if KOUI_MOUSE_CUSTOM_CURSOR
		switch (cursorType) {
			case Default:
				mouse.showSystemCursor();
				systemCursorHidden = false;
			default:
				mouse.hideSystemCursor();
				systemCursorHidden = true;
		}
		#else
		mouse.setSystemCursor(cursorType);
		#end
	}

	static function getCursorEnumValue(name: String): MouseCursor {
		if (name == null) return Default;

		return switch (name.toLowerCase()) {
			case "default": Default;
			case "pointer": Pointer;
			case "text": Text;
			case "wait": Wait;
			case "notallowed": NotAllowed;
			default: Default;
		}
	}

	#if KOUI_MOUSE_ACCEL
	static function calculateAccelMousePosition(x: Int, y: Int, deltaX: Int, deltaY: Int) {
		mouseX = x;
		mouseX += Std.int(deltaX * 0.7);
		mouseY = y;
		mouseY += Std.int(deltaY * 0.7);

		if (deltaX == 0) mouseX += Std.int((x - mouseX) * 0.3);
		if (deltaY == 0) mouseY += Std.int((y - mouseY) * 0.3);
	}
	#end

	/**
	 * Draws the cursor onto the screen.
	 *
	 * @param g `The kha.graphics2.Graphics` used to draw the cursor
	 */
	static #if !KOUI_MOUSE_CUSTOM_CURSOR inline #end function draw(g: kha.graphics2.Graphics) {
		#if KOUI_MOUSE_CUSTOM_CURSOR
		g.color = 0xffffffff;
		switch (type) {
			case Default:
			case Text:
				g.drawScaledSubImage(kha.Assets.images.cursor_text, 0, 0, 64, 64, mouseX - 16, mouseY - 16, 32, 32);
			case NotAllowed:
				g.drawScaledSubImage(kha.Assets.images.cursor_notallowed, 0, 0, 64, 64, mouseX - 16, mouseY - 16, 32, 32);
			default:
		}
		#end
	}
}
