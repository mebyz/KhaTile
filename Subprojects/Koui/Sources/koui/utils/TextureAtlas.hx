package koui.utils;

import koui.elements.Element;
import koui.graphics.KGraphics;

class TextureAtlas {
	/**
	 * Draws a part of the background texture of the given element to the given
	 *`Graphics` object.
	 *
	 * @param g
	 * @param element
	 * @param divisionsX How many times the texture is divided (tiled) on the x axis (default: 1)
	 * @param divisionsY How many times the texture is divided (tiled) on the y axis (default: 1)
	 * @param offsetX The x axis index of the tile that should be drawn, see `divisionsX` (default: 0)
	 * @param offsetY The y axis index of the tile that should be drawn, see `divisionsY` (default: 0)
	 * @param drawX Custom drawing position
	 * @param drawX Custom drawing position
	 * @return `true` if the background texture exists and was drawn, else `false`
	 */
	@:access(koui.elements.Element)
	public static function drawFromAtlas(g: KGraphics, element: Element, divisionsX: Int = 1, divisionsY: Int = 1,
			offsetX: Int = 0, offsetY: Int = 0, ?drawX: Int, ?drawY: Int): Bool {

		if (element.style.textureBg == "") {
			return false;
		}

		var texture = kha.Assets.images.get(element.style.textureBg);
		if (texture == null) {
			// TODO: Log.warnOnce() via macro
			return false;
		}

		if (drawX == null) drawX = element.drawX;
		if (drawY == null) drawY = element.drawY;

		var atlasX = 0;
		var atlasY = 0;
		var atlasW: Int;
		var atlasH: Int;

		if (element.style.atlas != null) {
			atlasX = element.style.atlas.x;
			atlasY = element.style.atlas.y;
			atlasW = element.style.atlas.w;
			atlasH = element.style.atlas.h;
		} else {
			atlasW = Std.int(texture.width / divisionsX);
			atlasH = Std.int(texture.height / divisionsY);
		}

		atlasX += atlasW * offsetX;
		atlasY += atlasH * offsetY;

		g.color = 0xffffffff;
		g.drawSubImage(texture, drawX, drawY, atlasX, atlasY, atlasW, atlasH);

		return true;
	}
}
