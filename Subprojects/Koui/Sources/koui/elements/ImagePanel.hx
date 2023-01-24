package koui.elements;

import koui.effects.Border;

/**
 * Draws an image to the screen. The class is called `ImagePanel` to avoid
 * conflicts with `kha.Image`.
 */
class ImagePanel extends Panel {
	/**
	 * The `kha.Image` object that should be drawn.
	 */
	public var image(default, set): Null<kha.Image>;

	/**
	 * If `true`, the image is scaled to the width and height of this element.
	 */
	public var scale = false;

	/**
	 * Create a new `ImagePanel` element.
	 *
	 * @param image The `kha.Image` object that should be drawn
	 */
	public function new(image: kha.Image) {
		super();
		this.image = image;
	}

	/**
	 * Set the scale setting of this image element.
	 *
	 * @param scale If `true`, the image is scaled to the given width and height
	 * @param width The width of the image panel
	 * @param height The height of the image panel
	 */
	public function setScale(scale: Bool, width: Int, height: Int) {
		this.scale = scale;
		this.layoutWidth = width;
		this.layoutHeight = height;
	}

	/**
	 * Set the image scale quality. Default: `Low`.
	 * @param quality `[High/Low]`
	 */
	public function setScaleQuality(quality: kha.graphics2.ImageScaleQuality) {
		this.image.g2.imageScaleQuality = quality;
		this.image.g2.mipmapScaleQuality = quality;
	}

	function set_image(img: Null<kha.Image>): Null<kha.Image> {
		this.image = img;
		if (img != null) {
			layoutHeight = this.image.realHeight;
			layoutWidth = this.image.realWidth;
		}
		return img;
	}

	/**
	 * Draw the image to the screen.
	 * @param g The `kha.graphics2.Graphics` object used for drawing
	 */
	override function draw(g: koui.graphics.KGraphics) {
		g.color = 0xffffffff;

		if (scale) g.drawScaledImage(this.image, drawX, drawY, drawWidth, drawHeight);
		else {
			g.drawImage(this.image, drawX, drawY);
		}

		Border.draw(g, this);
	}

}
