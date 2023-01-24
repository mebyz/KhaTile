package koui.elements.layouts;

import koui.elements.Element;
import koui.elements.layouts.Layout;

/**
 * A `ColLayout` is a layout that represents a single row of elements (a set
 * of multiple columns). Each column has the same size and can contain one
 * element only. If another element is added to the same column, the column's
 * current element is removed from the layout.
 */
class ColLayout extends GridLayout {
	/**
	 * Creates a new column layout.
	 * @param posX The x position of the layout
	 * @param posY The y position of the layout
	 * @param width The width of the layout
	 * @param height The height of the layout
	 * @param amountCols The amount of columns
	 */
	public function new(posX: Int, posY: Int, width: Int, height: Int, amountCols: Int) {
		super(posX, posY, width, height, 1, amountCols);
	}

	/**
	 * Adds an element to this `ColLayout` at the given position. Please note
	 * that if an element already exists at that position, it is removed from
	 * the layout.
	 *
	 * If the given position does not exist, an error is raised and the element
	 * is not added to this layout.
	 *
	 * @param element The given element
	 * @param column The column this element should be placed in
	 * @param anchor (Optional) The anchor of the element. If not given, use the
	 *               elements default anchor. Otherwise, the element's anchor
	 *               setting is overwritten.
	 */
	public function addToColumn(element: Element, column: Int, ?anchor: Anchor) {
		super.add(element, 0, column, anchor);
	}

	/**
	 * Removes the element at the given column from this layout.
	 * @param column The column of the element
	 */
	public function removeAtColumn(column: Int) {
		super.removeAtPosition(0, column);
	}
}
