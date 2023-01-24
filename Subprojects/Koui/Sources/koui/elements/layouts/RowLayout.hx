package koui.elements.layouts;

import koui.elements.Element;
import koui.elements.layouts.Layout;

/**
 * A `RowLayout` is a layout that represents a single column of elements (a set
 * of multple rows). Each row has the same size and can contain one element
 * only. If another element is added to the same row, the row's current element
 * is removed from the layout.
 */
class RowLayout extends GridLayout {
	/**
	 * Creates a new row layout.
	 * @param posX The x position of the layout
	 * @param posY The y position of the layout
	 * @param width The width of the layout
	 * @param height The height of the layout
	 * @param amountRows The amount of rows
	 */
	public function new(posX: Int, posY: Int, width: Int, height: Int, amountRows: Int) {
		super(posX, posY, width, height, amountRows, 1);
	}

	/**
	 * Adds an element to this `RowLayout` at the given position. Please note
	 * that if an element already exists at that position, it is removed from
	 * the layout.
	 *
	 * If the given position does not exist, an error is raised and the element
	 * is not added to this layout.
	 *
	 * @param element The given element
	 * @param row The row this element should be placed in
	 * @param anchor (Optional) The anchor of the element. If not given, use the
	 *               elements default anchor. Otherwise, the element's anchor
	 *               setting is overwritten.
	 */
	public function addToRow(element: Element, row: Int, ?anchor: Anchor) {
		super.add(element, row, 0, anchor);
	}

	/**
	 * Removes the element at the given row from this layout.
	 * @param row The row of the element
	 */
	public function removeAtRow(row: Int) {
		super.removeAtPosition(row, 0);
	}
}
