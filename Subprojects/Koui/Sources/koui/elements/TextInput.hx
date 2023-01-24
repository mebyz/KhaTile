package koui.elements;

import kha.FastFloat;
import kha.graphics2.HorTextAlignment;
import kha.graphics2.VerTextAlignment;

import koui.Config;
import koui.events.EventHandler;
import koui.events.FocusEvent;
import koui.events.KeyEvent.KeyCharPressEvent;
import koui.events.KeyEvent.KeyCodePressEvent;
import koui.events.KeyEvent.KeyCodeStatusEvent;
import koui.events.MouseEvent.MouseClickEvent;
import koui.events.MouseEvent.MouseHoverEvent;
import koui.theme.ThemeUtil;
import koui.utils.MathUtil;

using kha.graphics2.GraphicsExtension;
using koui.utils.StringUtil;

/**
 * A text input element is used to enter a single line of text. It has a label
 * that displays a prompt text when there is no text written to the text input.
 *
 * ![TextInput screenshot](https://gitlab.com/koui/Koui/-/wikis/images/elements/element_textinput.png)
 *
 * @see `NumberInput`
 */
class TextInput extends Element {
	/**
	 * The current value of this element. To set the text, use
	 * [`setText()`](#setText).
	 */
	public var text(default, null) = "";

	/**
	 * The label of this element. It is displayed instead of the text if `text`
	 * equals `""`.
	 */
	public var label(default, set) = "";

	/**
	 * The maximum length of the text.
	 *
	 * @see `koui.Config.textInputMaxLength`
	 */
	public var maxLength: Int = Config.textInputMaxLength;

	/**
	 * `true` if the text value of this `TextInput` is valid based on the
	 * regular expression set in `validationReg`. If this value is `false`, the
	 * text field is highlighted in a different color (theme property
	 * `"color_invalid"`).
	 *
	 * @see [`validationReg`](#validationReg)
	 */
	public var valid = true;

	/**
	 * A regular expression that checks whether the input text is a valid value
	 * for this text input. If `null`, no validation check is performed.
	 *
	 * @see `NumberInput`
	 */
	public var validationReg: EReg = null;

	var origText = "";
	var scrollBoundL = 0;
	var scrollBoundR = 0;

	var cursorIndex = 0;
	var cursorTimer = 0;

	var isHovered = false;
	var isClicked = false;
	var isFocused = false;
	var draggingEnabled = false;
	var selectionStartIndex = -1; // -1 = No selection

	/**
	 * Create a new `TextInput` element.
	 */
	public function new(label: String = "") {
		super();
		requireStates(["hover", "click"]);
		requireStates(["hover", "click"], "invalid");

		this.label = label;

		#if !KOUI_EVENTS_OFF
		addEventListener(MouseHoverEvent, _onHover);
		addEventListener(MouseClickEvent, _onClick);
		addEventListener(FocusEvent, _onFocus);
		addEventListener(KeyCharPressEvent, _onKeyCharPress);
		addEventListener(KeyCodePressEvent, _onKeyCodePress);
		addEventListener(KeyCodeStatusEvent, _onKeyCodeStatus);
		#end
	}

	override function onTIDChange() {
		ThemeUtil.requireOptGroups(["textinput"]);

		width = style.size.width;
		height = style.size.height;

		truncateMaxLength();
		recalcScrollBounds();
	}

	#if !KOUI_EVENTS_OFF
	function _onHover(event: MouseHoverEvent) {
		if (event.getState() == HoverActive) {
			isHovered = true;
		} else if (event.getState() == HoverEnd) {
			isHovered = false;
		}
	}

	function _onClick(event: MouseClickEvent) {
		switch (event.getState()) {
			case ClickStart:
				if (event.mouseButton == Left) {
					isClicked = true;

					cursorTimer = 0;
					cursorIndex = getTextIndexBeforePosition(getVisibleText()) + scrollBoundL;

					if (!EventHandler.isShiftDown || !isTextSelected()) {
						selectionStartIndex = cursorIndex;
					}

					var layoutOffset = getLayoutOffset()[0];
					if (EventHandler.mouseX > drawX + style.padding.left - layoutOffset
							&& EventHandler.mouseX < drawX + drawWidth - style.padding.right - layoutOffset) {
						draggingEnabled = true;
					}

					if (EventHandler.keyboard != null) EventHandler.keyboard.show();
				}
				else if (isFocused) {
					EventHandler.clearFocus();
					stopEdit();
				}

			case ClickHold:
				updateDragging();

			case ClickEnd:
				isClicked = false;
				draggingEnabled = false;
				if (EventHandler.keyboard != null) EventHandler.keyboard.hide();

				if (cursorIndex == selectionStartIndex) {
					selectionStartIndex = -1;
				}

			case ClickCancelled:
				isClicked = false;
				draggingEnabled = false;
				if (EventHandler.keyboard != null) EventHandler.keyboard.hide();
		}
	}

	function _onKeyCharPress(event: KeyCharPressEvent) {
		if (!StringUtil.canPrintChar(event.keyChar)) return;

		deleteSelectedText();
		insertText(event.keyChar, cursorIndex);
	}

	function _onKeyCodeStatus(event: KeyCodeStatusEvent) {
		if (event.getState() == KeyDown) {
			switch (event.keyCode) {
				case Return:
					EventHandler.clearFocus();
					stopEdit();

				case Escape:
					// If something is selected, unselect it
					if (isTextSelected()) {
						selectionStartIndex = -1;
					}
					// Else, deactivate and reset the text field
					else {
						stopEdit(true);
					}

				case Home:
					// Jump to the front
					if (EventHandler.isShiftDown) selectionStartIndex = cursorIndex;
					else selectionStartIndex = -1;

					cursorIndex = 0;
					resetScroll();

				case End:
					// Jump to the back
					if (EventHandler.isShiftDown) selectionStartIndex = cursorIndex;
					else selectionStartIndex = -1;

					cursorIndex = text.length;
					scrollBoundR = cursorIndex;
					recalcScrollBounds(false);

				case A:
					if (EventHandler.isCtrlDown) {
						selectAll();
					}

				default:
			}
		}
	}

	function _onKeyCodePress(event: KeyCodePressEvent) {
		cursorTimer = 0;

		switch (event.keyCode) {
			case Backspace:
				if (isTextSelected()) {
					deleteSelectedText();
					recalcScrollBounds();
				}
				else if (cursorIndex > 0) {
					cursorIndex--;
					text = text.substring(0, cursorIndex) + text.substring(cursorIndex + 1);

					if (scrollBoundR > text.length) scrollBoundR = text.length;
					// If the cursor is on the left side of the text input, the
					// remaining text comes in from the right and vice versa
					recalcScrollBounds(cursorIndex > Std.int((scrollBoundL + scrollBoundR) / 2));
				}

			case Delete:
				if (isTextSelected()) {
					deleteSelectedText();
				}
				else if (cursorIndex < text.length) {
					text = text.substring(0, cursorIndex) + text.substring(cursorIndex + 1);
					recalcScrollBounds();
				}

			case Left:
				// Move the cursor to the beginning or end of the current selection
				if (!EventHandler.isShiftDown && isTextSelected()) {
					cursorIndex = Std.int(Math.min(cursorIndex, selectionStartIndex));
					selectionStartIndex = -1;
					if (cursorIndex < scrollBoundL) {
						scrollBoundL = cursorIndex;
						recalcScrollBounds();
					}
				}
				else {
					// Start selection
					if (EventHandler.isShiftDown && !isTextSelected()) {
						selectionStartIndex = cursorIndex;
					}

					// Move the cursor
					if (cursorIndex > 0) {
						cursorIndex--;
					}
					if (cursorIndex < scrollBoundL + Std.int((scrollBoundR - scrollBoundL) * 0.25)) {
						scrollText(-1);
					}
				}

			case Right:
				if (!EventHandler.isShiftDown && isTextSelected()) {
					cursorIndex = Std.int(Math.max(cursorIndex, selectionStartIndex));
					selectionStartIndex = -1;
					if (cursorIndex > scrollBoundR) {
						scrollBoundR = cursorIndex;
						recalcScrollBounds(true);
					}
				}
				else {
					if (EventHandler.isShiftDown && !isTextSelected()) {
						selectionStartIndex = cursorIndex;
					}

					if (cursorIndex < text.length) {
						cursorIndex++;
					}
					if (cursorIndex > scrollBoundR - Std.int((scrollBoundR - scrollBoundL) * 0.25)) {
						scrollText(1);
					}

				}

			default:
		}
	}

	function _onFocus(event: FocusEvent) {
		switch(event.getState()) {
			case FocusGet: beginEdit();
			case FocusLoose: stopEdit();
		}
	}
	#end

	function beginEdit() {
		// Store original text
		origText = text;
		isFocused = true;

		EventHandler.block(this);
		EventHandler.registerCutCopyPaste(onCut, onCopy, onPaste);
	}

	function stopEdit(reset = false) {
		// Deselect on focus loose
		selectionStartIndex = -1;
		isFocused = false;
		resetScroll();

		if (reset) {
			text = origText;
		}
		origText = "";
		valid = isTextValid();

		EventHandler.unblock();
		EventHandler.unregisterCutCopyPaste();
	}

	inline function getVisibleText(): String {
		return text.substring(scrollBoundL, scrollBoundR);
	}

	/**
	 * Scroll the text input if the mouse is dragged outside of the bounds.
	 */
	function updateDragging() {
		if (!draggingEnabled) {
			return;
		}

		cursorTimer = 0;
		cursorIndex = getTextIndexBeforePosition(getVisibleText()) + scrollBoundL;
		cursorIndex = MathUtil.clampI(cursorIndex, scrollBoundL, scrollBoundR);

		var layoutOffset = getLayoutOffset()[0];
		var offsetLeft = EventHandler.mouseX - (drawX + style.padding.left - layoutOffset);
		var offsetRight = EventHandler.mouseX - (drawX + drawWidth - style.padding.right - layoutOffset);

		if (offsetLeft < 0) {
			scrollText(Std.int(offsetLeft / 10) - 1);
		} else if (offsetRight > 0) {
			scrollText(Std.int(offsetRight / 10) + 1);
		}
	}

	override public function draw(g: koui.graphics.KGraphics) {
		// =====================================================================
		// Background
		// =====================================================================
		if (this.isClicked) setContextState("click");
		else if (this.isHovered) setContextState("hover");
		else resetContext();

		if (!valid) setContextElement("invalid");

		g.fillKRect(drawX, drawY, drawWidth, drawHeight, style);

		var inputWidth: Int = drawWidth - style.padding.left - style.padding.right;

		// Draw selection
		if (this.selectionStartIndex > -1) {
			g.color = style.textinput.colorSelection;

			var selectionStartPos: FastFloat = getTextPositionAtIndex(selectionStartIndex) - getTextPositionAtIndex(scrollBoundL);
			var selectionCursorPos: FastFloat = getTextPositionAtIndex(cursorIndex) - getTextPositionAtIndex(scrollBoundL);

			// Don't draw selection further left or right as the text input
			selectionStartPos = MathUtil.clamp(selectionStartPos, 0, inputWidth);

			var selectionWidth: FastFloat = selectionCursorPos - selectionStartPos;
			selectionStartPos += drawX + style.padding.left;

			g.fillRect(selectionStartPos, drawY + (drawHeight - g.fontSize) / 2, selectionWidth, g.fontSize);
		}

		// Draw text
		g.fontSize = style.font.size;
		g.font = ThemeUtil.getFont();

		var textColor= style.color.text;
		var shownText = "";
		if (text != "") {
			shownText = text.substring(scrollBoundL, scrollBoundR);
		} else {
			textColor = style.textinput.colorLabel;
			shownText = label;
		}

		Style.withOverride(style.color, "text", textColor, () -> {
			g.drawKAlignedString(shownText, drawX + style.padding.left, drawY + drawHeight / 2, HorTextAlignment.TextLeft, VerTextAlignment.TextMiddle, style);
		});

		#if KOUI_DEBUG_TEXTINPUT
		g.color = 0xffff0000;
		g.fontSize = 14;
		g.drawRect(drawX + style.padding.left, drawY, inputWidth, drawHeight);
		g.drawString('L: $scrollBoundL, R: $scrollBoundR', drawX + drawWidth + 4, drawY - 2);
		g.drawString('Ln: ${shownText.length}, C: $cursorIndex', drawX + drawWidth + 4, drawY + 12);
		g.drawString('Sel: ${selectionStartIndex}', drawX + drawWidth + 4, drawY + 26);
		#end

		if (isFocused) drawCursor(g);
	}

	/**
	 * Return whether there is some text selected currently.
	 */
	public inline function isTextSelected(): Bool {
		return selectionStartIndex != -1;
	}

	/**
	 * Select all the text in this text input.
	 */
	public function selectAll() {
		if (text.length == 0) {
			return;
		}

		cursorIndex = text.length;
		selectionStartIndex = 0;
		scrollBoundR = cursorIndex;
		recalcScrollBounds(false);
	}

	/**
	 * Return the selected text.
	 */
	public function getSelectedText(): String {
		if (selectionStartIndex <= -1) return "";
		return this.text.substring(this.selectionStartIndex, this.cursorIndex);
	}

	/**
	 * Delete the currently selected text.
	 */
	public function deleteSelectedText() {
		if (!isTextSelected()) {
			return;
		}

		// Selected "to the right"
		if (cursorIndex >= selectionStartIndex) {
			text = text.substring(0, selectionStartIndex) + text.substring(cursorIndex);
			cursorIndex = selectionStartIndex;
		}

		// Selected "to the left"
		else {
			text = text.substring(0, cursorIndex) + text.substring(selectionStartIndex);
		}

		selectionStartIndex = -1;
	}

	/**
	 * Insert the given text at the given position. If the position is greater
	 * or equal than the length of the text, `newText` is inserted at the
	 * end of the element's current text. If the new text of this element is
	 * greater than [`maxLength`](#maxLength), the text is truncated.
	 */
	public function insertText(newText: String, position: Int) {
		if (text.length >= maxLength || position >= maxLength) {
			return;
		}

		koui.utils.FontUtil.loadGlyphsFromStringOptional(newText);

		text = text.substring(0, position) + newText + text.substring(position);
		truncateMaxLength();
		cursorIndex += newText.length;

		if (cursorIndex > scrollBoundR) scrollText(1);
		// `else` because scrollText() above already recalculates the scroll bounds
		else recalcScrollBounds();
	}

	inline function truncateMaxLength() {
		text = text.substr(0, maxLength);
	}

	/**
	 * Set the text of this text input.
	 */
	public function setText(text: String) {
		koui.utils.FontUtil.loadGlyphsFromStringOptional(text);

		this.text = text;
		valid = isTextValid();
		cursorIndex = 0;
		selectionStartIndex = -1;
		scrollBoundL = 0;
		draggingEnabled = false;

		recalcScrollBounds();
	}

	/**
	 * Return whether the text value of this element is valid according to the
	 * regular expression stored in `TextInput.validationReg`.
	 */
	public function isTextValid(): Bool {
		if (validationReg == null || text == "") return true;

		return validationReg.match(text);
	}

	inline function set_label(value: String): String {
		koui.utils.FontUtil.loadGlyphsFromStringOptional(text);
		return this.label = value;
	}

	function onCut(): String {
		var tmp = getSelectedText();
		deleteSelectedText();
		return tmp;
	}

	function onCopy(): String {
		return getSelectedText();
	}

	function onPaste(content: String) {
		deleteSelectedText();
		insertText(content, cursorIndex);
	}

	function resetScroll() {
		scrollBoundL = 0;
		recalcScrollBounds();
	}

	function scrollText(offset: Int) {
		// Ensure it is not scrolled to far
		var clampOffset = Std.int(Math.abs(offset));
		offset = Std.int(Math.max(offset, -scrollBoundL));
		offset = Std.int(Math.min(offset, (text.length - scrollBoundR)));

		offset = MathUtil.clampI(offset, -clampOffset, clampOffset);

		scrollBoundL += offset;
		scrollBoundR += offset;

		if (offset == 0) return;
		recalcScrollBounds(offset < 0);
	}

	/**
	 * Recalculates one of both `scrollBound[L/R]` variables based on the value
	 * of the other variable.
	 *
	 * The recalculated variable is determined based on whether `recalcRight` is
	 * `true` or `false`. If it is `true`, `scrollBoundR` is calculated based on
	 * the value in `scrollBoundL`. If it is `false`, it is calculated the other
	 * way around.
	 *
	 * @param recalcRight If `true`, calculate `scrollBoundR` based on `scrollBoundL`.
	 *                    If `false`, it is the other way around.
	 */
	function recalcScrollBounds(recalcRight = true) {
		scrollBoundL = MathUtil.clampI(scrollBoundL, 0, text.length);
		scrollBoundR = MathUtil.clampI(scrollBoundR, 0, text.length);

		var inputWidth = width - style.padding.left - style.padding.right;

		if (recalcRight) {
			scrollBoundR = scrollBoundL + getTextIndexBeforePosition(text.substr(scrollBoundL), inputWidth);
		} else {
			// reverse() to do the binary search from the other direction
			scrollBoundL = scrollBoundR - getTextIndexBeforePosition(text.substr(0, scrollBoundR).reverse(), inputWidth);
		}
	}

	function drawCursor(g: kha.graphics2.Graphics) {
		if (this.cursorTimer >= style.textinput.blinkInterval * 2) this.cursorTimer = 0;

		if (this.cursorTimer <= style.textinput.blinkInterval) {
			var charPosition = drawX + style.padding.left + getTextPositionAtIndex(cursorIndex) - getTextPositionAtIndex(scrollBoundL);
			g.color = style.textinput.colorCursor;
			g.fillRect(charPosition, drawY + (drawHeight - g.fontSize) / 2, 1, g.fontSize);
		}

		this.cursorTimer++;
	}

	/**
	 * Calculates the rightmost text index which position in `searchText` is
	 * smaller than `relPositionX` with binary search.
	 *
	 * If `searchText` is not given, `this.text` is used instead.
	 *
	 * If `relPositionX` is not given, the relative mouse position is used
	 * instead.
	 *
	 * @param searchText The text to be searched
	 * @param relPositionX The position in "text coordinates"
	 * @return Int
	 */
	function getTextIndexBeforePosition(?searchText: String, ?relPositionX: FastFloat): Int {
		if (relPositionX == null) relPositionX = EventHandler.mouseX - (this.drawX + style.padding.left - getLayoutOffset()[0]);
		if (searchText == null) searchText = this.text;

		var left = 0;
		var right = searchText.length - 1;
		var currentChar = 0;

		while (left <= right) {
			currentChar = Std.int((left + right) / 2);
			var tempText = searchText.substr(0, currentChar + 1);
			// Use FastFloat to make compilation to Android work
			var tmpTextWidth: FastFloat = ThemeUtil.getFont().width(style.font.size, tempText);
			var difference: FastFloat = relPositionX - tmpTextWidth;

			// Width of the current character
			var curCharWidth = ThemeUtil.getFont().width(style.font.size, searchText.charAt(currentChar));

			// Found the right position
			if (difference >= -curCharWidth && difference <= 0) break;

			// Selection is further left
			else if (difference < -curCharWidth) {
				right = currentChar - 1;
			}

			// Selection is further right (difference > 0)
			else {
				left = currentChar + 1;
			}
		}

		if (left > right) {
			// Too far right
			if (left != 0) currentChar++;
		}

		return currentChar;
	}

	inline function getTextPositionAtIndex(index: Int): FastFloat {
		return ThemeUtil.getFont().width(style.font.size, this.text.substr(0, index));
	}
}
