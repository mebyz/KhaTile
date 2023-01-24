package koui.elements;

import koui.events.FocusEvent;
import koui.events.KeyEvent.KeyCodeStatusEvent;
import koui.events.MouseEvent.MouseClickEvent;
import koui.events.MouseEvent.MouseHoverEvent;
import koui.events.MouseEvent.MouseScrollEvent;
import koui.events.EventHandler;
import koui.theme.ThemeUtil;
import koui.utils.TextureAtlas;

using kha.graphics2.GraphicsExtension;

/**
 * A drop-down menu is a list of options from which the user can choose exactly
 * one option. It works like a group of `RadioButton`s but takes up less visual
 * space. A drop-down menu also has a label that describes the set of options
 * that the user can choose from. The label is displayed when the drop-down menu
 * is active/open.
 *
 * ![Dropdown screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_dropdown.png)
 *
 * ```haxe
 * // Construct a new Dropdown with the label "DropdownLabel"
 * var myDropdown = new Dropdown("DropdownLabel");
 *
 * // Add some options
 * myDropdown.addOption("Option 1");
 * myDropdown.addOption("Option 2");
 * myDropdown.addOption("Option 3");
 *
 * // Select the first option
 * myDropdown.setSelectedOption("Option 1");
 * ```
 */
class Dropdown extends Element {
	/**
	 * The label of this element.
	 */
	public var label = "";
	/**
	 * The currently selected option.
	 *
	 * @see `Dropdown.setSelectedOption()`
	 */
	public var selectedOption(default, null) = "";
	/**
	 * All options of this dropdown menu.
	 */
	public var options: Array<String> = new Array();

	// -2 = not hovered, -1 = top hovered, 0-n = options hovered
	var hovered = -2;
	var isClicked = false;
	var isActive = false;

	// Height of the entire overlay (without the dropdown base itself)
	var overlayHeight: Int = 0;

	/**
	 * Create a new `Dropdown` element.
	 */
	public function new(label: String) {
		super();

		this.label = label;

		#if !KOUI_EVENTS_OFF
		addEventListener(MouseHoverEvent, _onHover);
		addEventListener(MouseClickEvent, _onClick);
		addEventListener(FocusEvent, _onFocus);
		addEventListener(KeyCodeStatusEvent, _onKeyCodeStatus);
		addEventListener(MouseScrollEvent, _onScroll);
		#end
	}

	override function initStyle() {
		requireStates(["hover", "click"]);
		requireStates(["hover", "click"], "option");
		requireStates(["hover", "click"], "option_selected");
		requireStates(["hover", "click"], "overlay_bg");
	}

	override function onTIDChange() {
		ThemeUtil.requireOptGroups(["dropdown"]);

		if (style.textureBg == "") {
			width = style.size.width;
			height = style.size.height;
		} else {
			width = style.atlas.w;
			height = style.atlas.h;
		}

		setOverlayHeight();
	}

	function setOverlayHeight() {
		resetContext();

		if (options.length == 0) {
			setContextElement("overlay_bg");
			this.overlayHeight = style.size.minHeight;
			resetContext();
			return;
		};

		var separatorSize = style.dropdown.separatorSize;

		setContextElement("option");
		this.overlayHeight = (style.size.height + separatorSize) * (options.length - 1);

		setContextElement("option_selected");
		this.overlayHeight += style.size.height + separatorSize;

		resetContext();
	}

	/**
	 * Add an option to the set of options.
	 */
	public function addOption(option: String) {
		options.push(option);
		if (options.length == 1) selectedOption = option;

		setOverlayHeight();
	}

	/**
	 * Remove an option from the set of options.
	 */
	public function removeOption(option: String) {
		options.remove(option);
		if (options.length == 1) selectedOption = option;

		setOverlayHeight();
	}

	/**
	 * Set the currently selected option. If the given option does not exist,
	 * a warning is printed and the previously set option will remain selected.
	 */
	public function setSelectedOption(option: String) {
		if (options.indexOf(option) == -1) {
			Log.warn('Dropdown option $option does not exist!');
			return;
		}
		selectedOption = option;
	}

	/**
	 * Close the dropdown menu.
	 */
	public function close() {
		if (hovered > -1) calculateHoverPos();
		isActive = false;
		setContextElement("");

		EventHandler.clearFocus();
		EventHandler.unblock();
		Koui.unregisterOverlay(this);
	}

	/**
	 * Calculates the correct value of the `hovered` variable.
	 */
	function calculateHoverPos() {
		resetContext();
		var relMouseY = EventHandler.mouseY - drawY + getLayoutOffset()[1];
		var rowHeight: Int = height + style.dropdown.separatorSize;
		hovered = Std.int(relMouseY / rowHeight) - 1;
	}

	override public function draw(g: koui.graphics.KGraphics) {
		var atlasOffsetY = isClicked && hovered == -1 ? 2 : (hovered == -1 ? 1 : 0);

		if (!TextureAtlas.drawFromAtlas(g, this, 2, 6, 0, atlasOffsetY)) {
			if (!isActive && hovered == -1) {
				isClicked ? setContextState("click") : setContextState("hover");
			} else {
				resetContext();
			}

			g.fillKRect(drawX, drawY, drawWidth, height, style);
		}

		var arrowSize = style.dropdown.arrowSize;
		if (arrowSize != 0) {
			g.color = style.dropdown.arrowColor;
			if (style.dropdown.arrowRight) {
				var padding = style.padding.right;

				if (isActive) g.pushRotation(-Math.PI / 2, drawX + drawWidth - padding - arrowSize / 2, drawY + height / 2);
				g.fillTriangle(
					drawX + drawWidth - padding, drawY + height / 2 - arrowSize / 2,
					drawX + drawWidth - padding, drawY + height / 2 + arrowSize / 2,
					drawX + drawWidth - padding - arrowSize, drawY + height / 2);
			} else {
				var padding = style.padding.left;

				if (isActive) g.pushRotation(Math.PI / 2, drawX + padding + arrowSize / 2, drawY + height / 2);
				g.fillTriangle(
					drawX + padding, drawY + height / 2 - arrowSize / 2,
					drawX + padding, drawY + height / 2 + arrowSize / 2,
					drawX + padding + arrowSize, drawY + height / 2);
			}
			if (isActive) g.popTransformation();
		}

		var drawText = isActive || options.length == 0 ? label : selectedOption;
		g.fontSize = style.font.size;
		g.font = ThemeUtil.getFont();
		g.color = style.color.text;

		if (style.dropdown.arrowRight) {
			g.drawKAlignedString(drawText, drawX + style.padding.left, drawY + height / 2, TextLeft, TextMiddle, style);
		} else {
			g.drawKAlignedString(drawText, drawX + style.padding.left * 2 + arrowSize, drawY + height / 2, TextLeft, TextMiddle, style);
		}
	}

	override public function drawOverlay(g: KGraphics) {
		this.drawHeight = this.height;

		if (!isActive) return;

		var separatorSize = style.dropdown.separatorSize;
		var separatorColor = style.dropdown.separatorColor;

		setContextElement("overlay_bg");
		g.opacity = style.opacity;
		g.fillKRect(drawX, drawY + separatorSize + height, drawWidth, overlayHeight, style);

		for (i in 0...options.length) {
			setContextElement("option");
			g.opacity = style.opacity;

			var option = options[i];

			var optionY = drawY + separatorSize * (i + 1) + height * (i + 1);

			var atlasOffsetY = 0;
			if (option == selectedOption) {
				setContextElement("option_selected");
				atlasOffsetY = 3;
				if (hovered == i) {
					atlasOffsetY = isClicked ? 5 : 4;
				}
			}
			if (hovered == i) {
				atlasOffsetY = isClicked ? 2 : 1;
			}

			if (!TextureAtlas.drawFromAtlas(g, this, 2, 6, 1, atlasOffsetY, drawX, optionY)) {
				// Draw option background
				if (hovered == i) {
					isClicked ? setContextState("click") : setContextState("hover");
				}

				g.fillKRect(drawX, optionY, drawWidth, height, style);
			}
			this.drawHeight += height;

			// Draw separator
			g.color = separatorColor;
			g.fillRect(drawX, drawY + drawHeight - height, drawWidth, separatorSize);
			this.drawHeight += separatorSize;

			g.drawKAlignedString(option, drawX + style.padding.left, drawY + drawHeight - height / 2, TextLeft, TextMiddle, style);

			setContextState("default");
		}
	}

	#if !KOUI_EVENTS_OFF
	function _onHover(event: MouseHoverEvent) {
		switch (event.getState()) {
			case HoverStart, HoverActive:
				if (event.mouseMoved) calculateHoverPos();
			case HoverEnd:
				hovered = -2;
		}
	}

	function _onClick(event: MouseClickEvent) {
		switch (event.getState()) {
			case ClickStart:
				switch(event.mouseButton) {
					case Left:
						if (isActive && hovered == -1) close();
						else isClicked = true;
					case Right: close();
					default:
				}
			case ClickHold:
			case ClickEnd, ClickCancelled:
				isClicked = false;
				if (hovered > -1) {
					if (hovered < options.length) {
						selectedOption = options[hovered];
					}
					close();
				}
		}
	}

	function _onFocus(event: FocusEvent) {
		switch(event.getState()) {
			case FocusGet:
				isActive = true;
				EventHandler.block(this);
				Koui.registerOverlay(this);
			case FocusLoose:
				close();
		}
	}

	function _onKeyCodeStatus(event: KeyCodeStatusEvent) {
		if (event.getState() == KeyDown) {
			switch (event.keyCode) {
				case Escape:
					close();
				case Up:
					if (hovered < 0) hovered = options.length;
					if (hovered > 0) hovered--;
				case Down:
					if (hovered < 0) hovered = -1;
					if (hovered < options.length - 1) hovered++;
				case Return:
					selectedOption = options[hovered];
					close();
				default:
			}
		}
	}

	function _onScroll(event: MouseScrollEvent) {
		// Same behaviour as arrow up/down keys
		if (event.scrollDelta < 0) {
			if (hovered < 0) hovered = options.length;
			if (hovered > 0) hovered--;
		} else if (event.scrollDelta > 0) {
			if (hovered < 0) hovered = -1;
			if (hovered < options.length - 1) hovered++;
		}
	}
	#end
}
