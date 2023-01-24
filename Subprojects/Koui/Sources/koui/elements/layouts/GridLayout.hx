package koui.elements.layouts;

import haxe.ds.Vector;

import koui.elements.Element;
import koui.elements.layouts.Layout.Anchor;
import koui.utils.Log;

/**
 * A `GridLayout` is a `Layout` that places elements into equal-sized grid
 * cells.
 *
 * Each cell can contain one element only. If another element is added,
 * the cell's current element is removed from the layout.
 */
class GridLayout extends Layout {
	// Vector of Vectors that represent rows of elements
	var elements: Vector<Vector<Element>>;

	var amountCols = 0;
	var amountRows = 0;
	var cellWidth = 0;
	var cellHeight = 0;

	/**
	 * Creates a new grid layout.
	 * @param posX The x position of the layout
	 * @param posY The y position of the layout
	 * @param width The width of the layout
	 * @param height The height of the layout
	 * @param amountRows The amount of rows in this layout
	 * @param amountCols The amount of columns in this layout
	 */
	public function new(posX: Int, posY: Int, width: Int, height: Int, amountRows: Int, amountCols: Int) {
		super(posX, posY, width, height);

		this.amountRows = amountRows;
		this.amountCols = amountCols;

		this.elements = new Vector(amountRows);
		for (row in 0...amountRows) {
			elements[row] = new Vector(amountCols);
		}

		this.cellWidth = Std.int(width / amountCols);
		this.cellHeight = Std.int(height / amountRows);
	}

	/**
	 * Adds an element to this `GridLayout` at the given position. Please note
	 * that if an element already exists at that position, it is removed from
	 * the layout.
	 *
	 * If the given position does not exist, an error is raised and the element
	 * is not added to this layout.
	 *
	 * @param element The given element
	 * @param row The row this element should be placed in
	 * @param column The column this element should be placed in
	 * @param anchor (Optional) The anchor of the element. If not given, use the
	 *               elements default anchor. Otherwise, the element's anchor
	 *               setting is overwritten.
	 */
	public function add(element: Element, row: Int, column: Int, ?anchor: Anchor) {
		if (row < 0 || row >= amountRows) {
			Log.error('GridLayout add(): given row index $row out of bounds, element $element was not added!');
			return;
		}
		if (column < 0 || column >= amountCols) {
			Log.error('GridLayout add(): calculated index $column out of bounds, element $element was not added!');
			return;
		}

		element.layout = this;
		if (anchor != null)	element.anchor = anchor;

		elements[row][column] = element;

		recalcElement(row, column);
	}

	/**
	 * Removes the given element from this layout.
	 *
	 * @param element The element
	 */
	public function remove(element: Element) {
		for (row in 0...elements.length) {
			for (col in 0...elements[0].length) {
				if (elements[row][col] == element) {
					elements[row][col].layout = null;
					elements[row][col] = null;
					return;
				}
			}
		}
	}

	/**
	 * Removes the element at the given position from this layout.
	 * @param row The row of the element
	 * @param column The column of the element
	 */
	public function removeAtPosition(row: Int, column: Int) {
		var element: Null<Element> = elements[row][column];
		if (element != null) {
			element.layout = null;
		}
		elements[row][column] = null;
	}

	function recalcElement(row: Int, column: Int) {
		var element = elements[row][column];
		if (element == null) return;

		var invalid = calcElementSize(element, cellWidth, cellHeight);

		switch (element.getAnchorResolved()) {
			case TopLeft, MiddleLeft, BottomLeft:
				element.layoutX = cellWidth * column + element.posX + paddingLeft;
			case TopCenter, MiddleCenter, BottomCenter:
				element.layoutX = Std.int(cellWidth * (column + 0.5) - element.layoutWidth / 2 + element.posX);
			case TopRight, MiddleRight, BottomRight:
				element.layoutX = cellWidth * (column + 1) - element.layoutWidth + element.posX - paddingRight;
			default:
		}

		switch (element.getAnchorResolved()) {
			case TopLeft, TopCenter, TopRight:
				element.layoutY = cellHeight * row + element.posY + paddingTop;
			case MiddleLeft, MiddleCenter, MiddleRight:
				element.layoutY = Std.int(cellHeight * (row + 0.5) - element.layoutHeight / 2 + element.posY);
			case BottomLeft, BottomCenter, BottomRight:
				element.layoutY = cellHeight * (row + 1) - element.layoutHeight + element.posY - paddingBottom;
			default:
		}

		// Ensure that the child elements of the element are also repositioned
		// if the element is a layout
		if (invalid || Std.isOfType(element, Expander)) {
			Layout.resizeIfLayout(element);
		}
	}

	public override function elemUpdated(element: Element) {
		for (row in 0...elements.length) {
			for (col in 0...elements[0].length) {
				if (elements[row][col] == element) {
					recalcElement(row, col);
					return;
				}
			}
		}
	}

	/**
	 * Resizes this layout. Used internally and will likely be replaced with
	 * a property setter override.
	 *
	 * @param width The new width of this layout
	 * @param height The new height of this layout
	 */
	public override function resize(width: Int, height: Int) {
		super.resize(width, height);

		this.cellWidth = Std.int(layoutWidth / amountCols);
		this.cellHeight = Std.int(layoutHeight / amountRows);

		for (row in 0...elements.length) {
			for (column in 0...elements[0].length) {
				if (needsValidation(elements[row][column])) {
					recalcElement(row, column);
				}
			}
		}
	}

	override function getAllElements(): Iterable<Element> {
		var flattened = new Array<Element>();

		for (row in elements) {
			for (element in row) {
				flattened.push(element);
			}
		}
		return flattened;
	}

	/**
	 * Returns the element at the given position in window coordinates or `null`
	 * if no element exists at that position.
	 *
	 * @param x The x position
	 * @param y The y position
	 */
	public override function getElementAtPosition(x: Int, y: Int): Null<Element> {
		// If the mouse is not over this GridLayout, don't check the contained
		// elements and return `null`.
		if (!this.isAtPosition(x, y)) return null;

		if (absorbEvents) return this;

		// Make coords relative to this layout
		x = x - layoutX;
		y = y - layoutY;

		// Iterate in reverse to ensure that the first drawn objects (from left
		// to right and from top to bottom) are the ones that are checked last.
		for (row in 1 - elements.length ... 1) {
			for (column in 1 - elements[0].length ... 1) {
				var element = elements[-row][-column];

				if (element == null || !element.visible) continue;

				var hit = element.getElementAtPosition(x, y);
				if (hit != null) return hit;

				if (element.isAtPosition(x, y)) return element;
			}
		}

		return null;
	}

	override function draw(g: koui.graphics.KGraphics) {
		g.pushTranslation(drawX, drawY);

		for (row in elements) {
			for (element in row) {
				if (element == null) continue;
				renderElement(g, element);
			}
		}

		#if KOUI_DEBUG_LAYOUT
		g.color = Config.DBG_COLOR_GRIDLAYOUT;
		g.font = Koui.font;
		g.fontSize = 16;

		for (row in 0...amountRows + 1) {
			g.drawLine(0, cellHeight * row, drawWidth, cellHeight * row);
		}
		for (col in 0...amountCols + 1) {
			g.drawLine(cellWidth * col, 0, cellWidth * col, drawHeight);
		}
		g.drawString('w: $drawWidth, h: $drawHeight, cw: $cellWidth, ch: $cellHeight', 0, 0);
		#end

		g.popTransformation();
	}
}
