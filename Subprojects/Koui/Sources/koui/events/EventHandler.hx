package koui.events;

import haxe.ds.Vector;

import koui.Koui;
import koui.theme.Style;
import koui.elements.Element;
import koui.events.FocusEvent;
import koui.events.KeyEvent.KeyCharPressEvent;
import koui.events.KeyEvent.KeyCodePressEvent;
import koui.events.KeyEvent.KeyCodeStatusEvent;
import koui.events.MouseEvent.MouseButton;
import koui.events.MouseEvent.MouseClickEvent;
import koui.events.MouseEvent.MouseHoverEvent;
import koui.events.MouseEvent.MouseScrollEvent;
import koui.utils.Cursor;


/**
 * Responsible for the event handling of elements.
 */
class EventHandler {
	/**
	 * The x position of the mouse
	 */
	public static var mouseX(default, null) = 0;
	/**
	 * The y position of the mouse
	 */
	public static var mouseY(default, null) = 0;
	/**
	 * The delta x position of the mouse (the difference of the x position to
	 * the last frame)
	 */
	public static var mouseDX(default, null) = 0;
	/**
	 * The delta y position of the mouse (the difference of the y position to
	 * the last frame)
	 */
	public static var mouseDY(default, null) = 0;

	/**
	 * `true` if the `Ctrl` key is held down.
	 */
	public static var isCtrlDown(default, null) = false;
	/**
	 * `true` if the `Shift` key is held down.
	 */
	public static var isShiftDown(default, null) = false;
	/**
	 * `true` if the `Alt` key is held down.
	 */
	public static var isAltDown(default, null) = false;

	public static var mouse(default, null): Null<kha.input.Mouse>;
	public static var keyboard(default, null): Null<kha.input.Keyboard>;

	/**
	 * All currently active events.
	 */
	static var events: Map<Element, Array<Event>> = new Map<Element, Array<Event>>();

	static var mouseMoved = false;
	static var mousePressed: Vector<Bool> = new Vector<Bool>(3);
	static var lastPressedKey: Null<kha.input.KeyCode> = null;
	static var lastPressedKeyActive = false;
	static var lastPressedTime = 0.0;

	static var elemHovered: Null<Element> = null;
	static var elemFocused: Null<Element> = null;
	static var elemBlocking: Null<Element> = null;
	/**
	 * Unblock on the next click event
	 */
	static var markUnblock = false;
	/**
	 * `true` if the window is in the background and not focused.
	 */
	static var inBackground = false;

	public static function init() {
		#if !(kha_android || kha_ios)
			mouse = kha.input.Mouse.get();

			#if !KOUI_CUSTOM_INPUT
				mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseScroll, onMouseLeave);
			#end
		#end

		keyboard = kha.input.Keyboard.get();
		#if !KOUI_CUSTOM_INPUT
			keyboard.notify(onKeyboardDown, onKeyboardUp, onKeyboardPress);
		#end

		#if ((kha_android || kha_ios) && !KOUI_CUSTOM_INPUT)
			if (kha.input.Surface.get() != null) kha.input.Surface.get().notify(onTouchStart, onTouchEnd, onTouchMove);
		#end

		kha.System.notifyOnApplicationState(onForeground, onResume, onPause, onBackground, onShutdown);
	}

	public static function registerElement(element: Element) {
		events[element] = new Array<Event>();
	}

	/**
		Adds an event to the event array. Events are sent in an update loop and
		not directly at the moment they happen to prevent stack overflows
		through circular calls and to make the overall process more stable.
	**/
	public static inline function addEvent(event: Event) {
		if (event.element == null) return;
		events[event.element].push(event);
		// Event.dispatch(event);
	}

	/**
	 * Cancels ALL events. Used internally most of the time.
	 */
	public static function reset() {
		for (element in events.keys()) {
			events[element] = new Array<Event>();
		}
	}

	/**
	 * Updates all the events and calls registered listeners. Used internally
	 * most of the time.
	 */
	public static function update() {
		if (inBackground) return;

		#if KOUI_MOUSE_ACCEL
		Cursor.calculateAccelMousePosition(mouseX, mouseY, mouseDX, mouseDY);
		#end

		// mouseDX = 0;
		// mouseDY = 0;

		if (mouseMoved) checkMouseHover();
		checkMousePressed();
		checkKeyCodePress();

		for (element in events.keys()) {
			if (elemBlocking != null && element != elemBlocking) continue;
			if (element.disabled) continue;

			for (event in events[element]) {
				Event.dispatch(event);
			}
		}

		if (markUnblock) {
			elemBlocking = null;

			// Check again for hovering if unblocking when hovering over another
			// element
			checkMouseHover();

			// Set to false not before checkMouseHover() so that it works
			// correctly
			markUnblock = false;

		}
		mouseMoved = false;
	}

	@:allow(koui.elements.Element)
	static function clearFocus() {
		addEvent(new FocusEvent(elemFocused, FocusLoose, Left));
		elemFocused = null;
	}

	@:allow(koui.elements.Element)
	static function block(actuator: Element) {
		if (elemFocused != actuator) {
			trace('EventHandler warning: Cannot block, element $actuator is not focused! Focused: $elemFocused');
			return;
		}

		elemBlocking = actuator;
	}

	/**
	 * Unblocks the currently blocking element. The unblocking takes place in
	 * the next frame to not react to ongoing events. The `forceNow` parameter
	 * is a way around that behaviour.
	 *
	 * @param forceNow If `true`, already unblock in the current frame
	 */
	@:allow(koui.elements.Element)
	static function unblock(?forceNow = false) {
		if (forceNow) elemBlocking = null;

		else markUnblock = true;
	}

	public static inline function registerCutCopyPaste(onCut: Void -> String, onCopy: Void -> String, onPaste: String -> Void) {
		kha.System.notifyOnCutCopyPaste(onCut, onCopy, onPaste);
	}

	public static inline function unregisterCutCopyPaste() {
		kha.System.notifyOnCutCopyPaste(null, null, null);
	}

	static function onForeground() { inBackground = false; }
	static function onResume() {}
	static function onPause() {}
	static function onBackground() { inBackground = true; Cursor.setCursor(Default); }
	static function onShutdown() {}

	#if KOUI_CUSTOM_INPUT public #end
	static function onMouseDown(button: Int, x: Int, y: Int) {
		addEvent(new MouseClickEvent(elemHovered, ClickStart, button));

		if (elemFocused != elemHovered) {
			addEvent(new FocusEvent(elemFocused, FocusLoose, button));

			if (button == Left) {
				if (elemBlocking == null || elemBlocking == elemHovered) elemFocused = elemHovered;
				else elemFocused = null;

				addEvent(new FocusEvent(elemFocused, FocusGet, button));
			}
			else elemFocused = null;
		}

		mousePressed[button] = true;
	}

	#if KOUI_CUSTOM_INPUT public #end
	static function onMouseUp(button: Int, x: Int, y: Int) {
		if (elemFocused == elemHovered) {
			addEvent(new MouseClickEvent(elemFocused, ClickEnd, button));
		} else {
			addEvent(new MouseClickEvent(elemFocused, ClickCancelled, button));
		}

		mousePressed[button] = false;
	}

	#if KOUI_CUSTOM_INPUT public #end
	static function onMouseMove(x: Int, y: Int, deltaX: Int, deltaY: Int) {
		mouseX = x;
		mouseY = y;
		mouseDX = deltaX;
		mouseDY = deltaY;
		mouseMoved = true;

		#if !KOUI_MOUSE_ACCEL
		Cursor.setPosition(x, y);
		#end
	}

	#if KOUI_CUSTOM_INPUT public #end
	static function onMouseScroll(scrollDelta: Int) {
		var receivingElement = getListeningParent(elemHovered, MouseScrollEvent);
		addEvent(new MouseScrollEvent(receivingElement, Scroll, scrollDelta));
	}

	#if KOUI_CUSTOM_INPUT public #end
	static function onMouseLeave() {}

	/**
	 * Called on the first frame a key is pressed down.
	 *
	 * @param key The keycode of the key
	 */
	#if KOUI_CUSTOM_INPUT public #end
	static function onKeyboardDown(key: kha.input.KeyCode) {
		addEvent(new KeyCodeStatusEvent(elemFocused, KeyDown, key));

		// Simulate a similar behaviour to how "onKeyboardPress()" works
		lastPressedKey = key;
		lastPressedTime = kha.Scheduler.time() + Config.keyRepeatDelay;
		lastPressedKeyActive = true;

		if (key == Control) isCtrlDown = true;
		if (key == Shift) isShiftDown = true;
		if (key == Alt) isAltDown = true;
	}

	/**
	 * Called on the first frame a key is no longer pressed down.
	 *
	 * @param key The keycode of the key
	 */
	#if KOUI_CUSTOM_INPUT public #end
	static function onKeyboardUp(key: kha.input.KeyCode) {
		addEvent(new KeyCodeStatusEvent(elemFocused, KeyUp, key));
		if (lastPressedKey == key) lastPressedKey = null;

		if (key == Control) isCtrlDown = false;
		if (key == Shift) isShiftDown = false;
		if (key == Alt) isAltDown = false;
	}

	/**
	 * Called when a key is pressed down. Note that this is called once on the
	 * first frame the key is pressed and after that on a certain time interval
	 * to simulate a OS-like input behaviour. Also, this method is only called
	 * by keys that represent a character.
	 *
	 * @param char The character that is pressed down
	 */
	#if KOUI_CUSTOM_INPUT public #end
	static function onKeyboardPress(char: String) {
		addEvent(new KeyCharPressEvent(elemFocused, KeyHold, char));
	}

#if (kha_android || kha_ios)
	#if KOUI_CUSTOM_INPUT public #end
	static function onTouchStart(fingerID: Int, x: Int, y: Int) {
		mouseX = x;
		mouseY = y;
		checkMouseHover();
		onMouseDown(Left, x, y);
	}

	#if KOUI_CUSTOM_INPUT public #end
	static function onTouchEnd(fingerID: Int, x: Int, y: Int) {
		onMouseUp(Left, x, y);
	}

	#if KOUI_CUSTOM_INPUT public #end
	static function onTouchMove(fingerID: Int, x: Int, y: Int) {
		mouseX = x;
		mouseY = y;
		checkMouseHover();
	}
#end

	static function checkMouseHover() {
		var newElemHovered = getListeningParent(Koui.getElementAtPosition(mouseX, mouseY), MouseHoverEvent);

		if (newElemHovered != elemHovered || markUnblock) {
			addEvent(new MouseHoverEvent(elemHovered, HoverEnd, true));
			addEvent(new MouseHoverEvent(newElemHovered, HoverStart, true));

			if (elemBlocking == null || elemBlocking == newElemHovered) elemHovered = newElemHovered;
			else elemHovered = null;

			if (elemHovered != null) {
				if (elemHovered.disabled) Cursor.setCursor(Cursor.getCursorEnumValue(Style.getStyle(elemHovered.tID).cursors.notallowed));
				else Cursor.setCursor(Cursor.getCursorEnumValue(Style.getStyle(elemHovered.tID).cursors.defaultCursor));
			} else {
				if (elemBlocking == null) Cursor.setCursor(Default);
			}
		}
		else addEvent(new MouseHoverEvent(newElemHovered, HoverActive, mouseMoved));
	}

	static function checkMousePressed() {
		for (button in 0...mousePressed.length) {
			if (mousePressed[button]) {
				addEvent(new MouseClickEvent(elemFocused, ClickHold, button));
			}
		}
	}

	public static function checkKeyCodePress() {
		if (lastPressedKey == null) return;

		if (lastPressedKeyActive) {
			addEvent(new KeyCodePressEvent(elemFocused, KeyDown, lastPressedKey));
			lastPressedKeyActive = false;
		}
		else if (kha.Scheduler.time() - lastPressedTime > Config.keyRepeatPeriod) {
			addEvent(new KeyCodePressEvent(elemFocused, KeyHold, lastPressedKey));
			lastPressedTime = kha.Scheduler.time();
		}
	}

	/**
	 * Return the lowest element in the parent/layout hierarchy (beginning with
	 * and including the passed element) that listens to the given event type.
	 */
	static function getListeningParent(element: Null<Element>, eventClass: Class<Event>): Null<Element> {
		if (element == null) {
			return null;
		}

		var currentElement = element;
		var eventTypeUID = Event.getTypeUID(eventClass);

		do {
			if (currentElement.listensToUID(eventTypeUID)) {
				return currentElement;
			}
			if (currentElement.parent == null) {
				break;
			}
			currentElement = currentElement.parent;
		} while (currentElement.parent != null);

		return null;
	}
}
