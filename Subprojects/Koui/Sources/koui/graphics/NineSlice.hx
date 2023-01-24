package koui.graphics;

import haxe.ds.Vector;
import kha.FastFloat;

/**
 * Implementation of [9-slice scaling](https://en.wikipedia.org/wiki/9-slice_scaling).
 * There is currently no support for tiling, the sub-images are scaled to the
 * size of the target tiles.
 *
 * To enable 9-slice scaling in the theme:
 *
 * - set `textureBg` to the Kha asset name of the background image
 * - set the `atlas` values according to the inner (center) slice
 * - set `border.nineSlice` to `true`
 */
class NineSlice {
	/**
	 * Creates the individual slice rectangles required for rendering, used
	 * internally most of the time.
	 *
	 * It returns a vector of two `Vector<Rect>`:
	 *
	 * - the first vector holds source image slices (not scaled) to be used as
	 *   texture coordinates
	 * - the second vector holds element slices (scaled to target) to be used
	 *   for the actual scaled drawing
	 *
	 * @param imgInnerSlice A rectangle defining the inner slice of the source image
	 * @param imgWidth The width of the source image
	 * @param imgHeight The height of the source image
	 * @param elemWidth The width of the element to which 9-slice scaling should be applied
	 * @param elemHeight The height of the element to which 9-slice scaling should be applied
	 */
	public static function createSlices(
			imgInnerSlice: Rect, imgWidth: FastFloat, imgHeight: FastFloat,
			elemWidth: FastFloat, elemHeight: FastFloat): Vector<Vector<Rect>> {

		var out = new Vector<Vector<Rect>>(2);
		out[0] = _createImageSlices(imgInnerSlice, imgWidth, imgHeight);
		out[1] = _createElemSlices(out[0], elemWidth, elemHeight);
		return out;
	}

	static function _createImageSlices(innerSlice: Rect, targetWidth: FastFloat, targetHeight: FastFloat): Vector<Rect> {
		var left = innerSlice.left;
		var right = innerSlice.right;
		var top = innerSlice.top;
		var bottom = innerSlice.bottom;

		var width = innerSlice.width;
		var height = innerSlice.height;

		return _createSlices(left, right, top, bottom, width, height, targetWidth, targetHeight);
	}

	static function _createElemSlices(imageSlices: Vector<Rect>, targetWidth: FastFloat, targetHeight: FastFloat): Vector<Rect> {
		// Use the already computed source image slices
		var left = imageSlices[TopLeft].width;
		var right = targetWidth - imageSlices[TopRight].width;
		var top = imageSlices[TopLeft].height;
		var bottom = targetHeight - imageSlices[BottomLeft].height;

		var width = right - left;
		var height = bottom - top;

		return _createSlices(left, right, top, bottom, width, height, targetWidth, targetHeight);
	}

	static function _createSlices(
			left: FastFloat, right: FastFloat, top: FastFloat, bottom: FastFloat,
			width: FastFloat, height: FastFloat, targetWidth: FastFloat, targetHeight: FastFloat): Vector<Rect> {

		var slices: Vector<Rect> = new Vector(9);

		slices[TopLeft] = new Rect(0, 0, left, top);
		slices[TopCenter] = new Rect(left, 0, width, top);
		slices[TopRight] = new Rect(right, 0, targetWidth - right, top);

		slices[MiddleLeft] = new Rect(0, top, left, height);
		slices[MiddleCenter] = new Rect(left, top, width, height);
		slices[MiddleRight] = new Rect(right, top, targetWidth - right, height);

		slices[BottomLeft] = new Rect(0, bottom, left, targetHeight - bottom);
		slices[BottomCenter] = new Rect(left, bottom, width, targetHeight - bottom);
		slices[BottomRight] = new Rect(right, bottom, targetWidth - right, targetHeight - bottom);

		return slices;
	}
}

// TODO: Combine with Anchor
enum abstract Pos9(Int) from Int to Int {
	var TopLeft;
	var TopCenter;
	var TopRight;
	var MiddleLeft;
	var MiddleCenter;
	var MiddleRight;
	var BottomLeft;
	var BottomCenter;
	var BottomRight;
}
