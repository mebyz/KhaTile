package koui;

import haxe.ds.Vector;

import kha.Framebuffer;
import kha.Image;

import koui.graphics.KGraphics;
import koui.effects.Effect;
import koui.elements.Element;
import koui.elements.layouts.AnchorPane;
import koui.elements.layouts.Layout.Anchor;
import koui.events.EventHandler;
import koui.theme.Style;
import koui.utils.Cursor;
#if KOUI_DEBUG_DRAWINGTIME
import koui.utils.MathUtil;
#end
import koui.utils.SceneManager;

/**
 * Koui's main class.
 */
class Koui {
	public static inline var KOUI_VERSION = "2020.10";

	/**
	 * The theme's root `kha.Font` object (for initialization of components).
	 * Used internally only.
	 */
	public static var font(default, null): kha.Font;
	/**
	 * The theme's root font size (for initialization of components).
	 * Used internally only.
	 */
	public static var fontSize(default, null): Int;

	/** True after Koui was successfully initialized. */
	public static var initialized(default, null) = false;

	/**
	 * The default layout. Gets initialized in `init()`.
	 */
	static var anchorPane: AnchorPane;
	static var overlays: Array<Element> = new Array();
	// Two arrays to compensate for the not existing ordered map data type
	static var overlay_offsets: Array<Vector<Int>> = new Array();

	static var backbuffer: Image;
	static var g: koui.graphics.KGraphics;

	#if KOUI_DEBUG_DRAWINGTIME
	public static var numDrawCalls = 0;
	public static var bufferSizes: Array<Int>;
	#end

	/**
	 * Initializes Koui. Call this in your application's initialization method.
	 * @param done Called after Koui successfully initialized and loaded all assets.
	 */
	public static function init(done: Void->Void) {
		Style.init();

		KGraphics.initTextPipeline();

		var windowId = 0;
		var screenWidth = kha.Window.get(windowId).width;
		var screenHeight = kha.Window.get(windowId).height;
		var antialiasing = 1;

		backbuffer = Image.createRenderTarget(screenWidth, screenHeight, null, NoDepthAndStencil, antialiasing);
		g = new KGraphics(backbuffer);

		anchorPane = new AnchorPane(0, 0, screenWidth, screenHeight);

		kha.Assets.loadEverything(function() {
			Cursor.init();

			Koui.font = g.font = kha.Assets.fonts.get(Style.getStyle("_root").font.family);
			Koui.fontSize = g.fontSize = Style.getStyle("_root").font.size;

			// EventHandler calls setCursor(), so it must be initialized after
			// the Cursor class
			EventHandler.init();

			kha.Window.get(windowId).notifyOnResize(onResize);

			initialized = true;
			done();
		}, filterAssets);
	}

	static inline function filterAssets(asset: Dynamic): Bool {
		return Style.requiredAssets.indexOf(asset.name) != -1;
	}

	/**
	 * Adds an element to be drawn.
	 * @param element The element
	 * @param anchor The anchor position of the new element.
	 */
	public static inline function add(element: Element, anchor: Anchor = TopLeft) {
		anchorPane.add(element, anchor);
	}

	/**
	 * Removes an element from the drawing list.
	 * @param element The element
	 */
	public static inline function remove(element: Element) {
		anchorPane.remove(element);
	}

	/**
	 * Sets the padding values of the default `AnchorPane`.
	 * @param left The left padding
	 * @param right The right padding
	 * @param top The top padding
	 * @param bottom The bottom padding
	 */
	public static inline function setPadding(left: Int, right: Int, top: Int, bottom: Int) {
		anchorPane.setPadding(left, right, top, bottom);
	}

	/**
	 * Sets the left padding of the default `AnchorPane`.
	 * @param paddingLeft The left padding
	 */
	public static inline function setPaddingLeft(left: Int) { anchorPane.paddingLeft = left; }

	/**
	 * Sets the right padding of the default `AnchorPane`.
	 * @param paddingRight The right padding
	 */
	public static inline function setPaddingRight(right: Int) { anchorPane.paddingRight = right; }

	/**
	 * Sets the top padding of the default `AnchorPane`.
	 * @param paddingTop The top padding
	 */
	public static inline function setPaddingTop(top: Int) { anchorPane.paddingTop = top; }

	/**
	 * Sets the bottom padding of the default `AnchorPane`.
	 * @param paddingBottom The bottom padding
	 */
	public static inline function setPaddingBottom(bottom: Int) { anchorPane.paddingBottom = bottom; }

	public static inline function registerOverlay(element: Element) {
		overlays.push(element);
		// Static overlay position for now
		overlay_offsets.push(element.getLayoutOffset());
	}

	public static inline function unregisterOverlay(element: Element) {
		var pos = overlays.indexOf(element);
		overlays.remove(element);
		overlay_offsets.remove(overlay_offsets[pos]);
	}

	/**
	 * Main drawing method responsible for drawing everything. Call this in you
	 * render loop.
	 * @param g2 The `kha.graphics2.Graphics` object for drawing
	 */
	public static function render(g2: kha.graphics2.Graphics) {
		if (!initialized) return;
		if (kha.System.windowWidth() == 0 || kha.System.windowHeight() == 0) return;

		#if KOUI_DEBUG_DRAWINGTIME
		var startTime = kha.Scheduler.realTime();
		numDrawCalls = 0;
		bufferSizes = new Array();
		#end

		#if !KOUI_EVENTS_OFF
		EventHandler.update();
		#end

		g.begin(true, 0x00000000);
		anchorPane.draw(g);
		for (i in 0...overlays.length) {
			var offset = overlay_offsets[i];
			g.pushTranslation(-offset[0], -offset[1]);

			var overlayElem = overlays[i];
			overlayElem.resetContext();
			if (overlayElem.disabled) overlayElem.setContextState("disabled");

			overlayElem.drawOverlay(g);

			g.popTransformation();
		}
		g.end();

		#if !KOUI_EVENTS_OFF
		EventHandler.reset();
		#end

		g2.begin(false);
		g2.color = kha.Color.White;
		g2.opacity = 1;
		g2.drawImage(backbuffer, 0, 0);
		Cursor.draw(g2);

		#if KOUI_DEBUG_DRAWINGTIME
		g2.color = 0xffff0000;
		g2.font = font;
		g2.fontSize = 16;
		g2.drawString('Total time: ${kha.Scheduler.realTime() - startTime}', 0, 0);
		// Only KGraphics draw calls
		g2.drawString('Draw calls: $numDrawCalls', 0, 18);
		g2.drawString('Avg buffer size: ${MathUtil.arrayAvgI(bufferSizes)}', 0, 36);
		#end

		g2.end();

		for (elem in Element.invalidations) {
			if (elem.layout != null) {
				elem.layout.elemUpdated(elem);
			}
		}
		Element.invalidations.clear();
	}

	/**
	 * Returns the topmost element at the given position. If no element exists
	 * at that position, `null` is returned.
	 *
	 * @param x The position's x coordinate
	 * @param y The position's y coordinate
	 * @return The element at the given position or `null` if not found
	 */
	public static function getElementAtPosition(x: Int, y: Int): Null<Element> {
		// Check overlayed elements first
		var sorted_overlays = overlays.copy();

		// Reverse to ensure that the topmost element is selected
		sorted_overlays.reverse();

		for (i in 0...sorted_overlays.length) {
			var element = sorted_overlays[i];
			var offset = overlay_offsets[i];

			var relX = x + offset[0];
			var relY = y + offset[1];

			if (element.isAtPosition(relX, relY)) return element;
		}

		// If no overlay was hit, check the other objects
		return anchorPane.getElementAtPosition(x, y);
	}

	static function onResize(width: Int, height: Int) {
		if (kha.System.windowWidth() == 0 || kha.System.windowHeight() == 0) return;

		// This also resizes scenes
		anchorPane.resize(width, height);

		backbuffer = Image.createRenderTarget(width, height, null, NoDepthAndStencil, 1);
		g = new KGraphics(backbuffer);
	}
}
