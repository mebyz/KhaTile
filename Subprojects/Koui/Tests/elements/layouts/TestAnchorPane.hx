package elements.layouts;

import utest.Assert;

import koui.elements.Button;
import koui.elements.Element;
import koui.elements.layouts.AnchorPane;
import koui.elements.layouts.Layout.Anchor;
import koui.theme.Style;

@:access(koui.elements.Button)
@:access(koui.elements.layouts.AnchorPane)
class TestAnchorPane extends utest.Test {

	var anchorPane: AnchorPane;
	var button: Button;

	function setup() {
		this.anchorPane = new AnchorPane(0, 0, 200, 100);
		this.button = new Button("Hello World!");
		button.setSize(40, 20);
	}

	function teardown() {}

	function testAddRemove() {
		Assert.notContains(cast(button, Element), anchorPane.elements);
		Assert.isNull(button.layout);

		anchorPane.add(button, Anchor.BottomRight);

		Assert.contains(cast(button, Element), anchorPane.elements);
		Assert.isTrue(button.anchor == Anchor.BottomRight);
		Assert.equals(anchorPane, button.layout);

		anchorPane.remove(button);
		Assert.notContains(cast(button, Element), anchorPane.elements);
		Assert.isNull(button.layout);
	}

	@:depends(testAddRemove)
	function testAnchorPoints() {
		// =====================================================================
		// Without padding
		// =====================================================================
		button.setPosition(20, 10);
		anchorPane.setPosition(50, 50);

		anchorPane.add(button, Anchor.TopLeft);
		Assert.equals(20, button.layoutX);
		Assert.equals(10, button.layoutY);
		anchorPane.remove(button);

		anchorPane.add(button, Anchor.MiddleCenter);
		Assert.equals(100 - 20 + 20, button.layoutX); // center - half element size + x position
		Assert.equals(50 - 10 + 10, button.layoutY); // middle - half element size + y position
		anchorPane.remove(button);

		anchorPane.add(button, Anchor.BottomRight);
		Assert.equals(200 - 40 + 20, button.layoutX); // right - element size + x position
		Assert.equals(100 - 20 + 10, button.layoutY); // bottom - element size + y position
		anchorPane.remove(button);

		// =====================================================================
		// With padding
		// =====================================================================
		anchorPane.setPadding(10, 20, 30, 40); // Left, Right, Top, Bottom

		anchorPane.add(button, Anchor.TopLeft);
		Assert.equals(20 + 10, button.layoutX);
		Assert.equals(10 + 30, button.layoutY);
		anchorPane.remove(button);

		anchorPane.add(button, Anchor.MiddleCenter);
		Assert.equals(100 - 20 + 20, button.layoutX); // center - half element size + x position, no padding
		Assert.equals(50 - 10 + 10, button.layoutY); // middle - half element size + y position, no padding
		anchorPane.remove(button);

		anchorPane.add(button, Anchor.BottomRight);
		Assert.equals(200 - 40 + 20 - 20, button.layoutX); // right - element size + x position - paddingRight
		Assert.equals(100 - 20 + 10 - 40, button.layoutY); // bottom - element size + y position - paddingBottom
		anchorPane.remove(button);

		// =====================================================================
		// With padding & resize elements
		// =====================================================================
		button.setPosition(20, 10);

		Assert.equals(40, button.layoutWidth);
		Assert.equals(20, button.layoutHeight);
		Assert.equals(200, anchorPane.layoutWidth);
		Assert.equals(100, anchorPane.layoutHeight);

		// Size should be independent of position
		anchorPane.setPosition(200, 200);

		Style.withOverride(button.style.size, "minWidth", 20, () -> {
			Style.withOverride(button.style.size, "minHeight", 20, () -> {
				anchorPane.add(button, Anchor.TopLeft);
				Assert.equals(200 - 10 - 20 - 20, button.layoutWidth); // width - padding R/L - positionX
				Assert.equals(100 - 30 - 40 - 10, button.layoutHeight); // height - padding T/D - positionY
				anchorPane.remove(button);

				anchorPane.add(button, Anchor.MiddleCenter);
				Assert.equals(200 - 10 - 20 - 20, button.layoutWidth); // width - padding R/L - positionX
				Assert.equals(100 - 30 - 40 - 10, button.layoutHeight); // height - padding T/D - positionY
				anchorPane.remove(button);

				anchorPane.add(button, Anchor.BottomRight);
				Assert.equals(200 - 10 - 20 + 20, button.layoutWidth); // width - padding R/L + positionX
				Assert.equals(100 - 30 - 40 + 10, button.layoutHeight); // height - padding T/D + positionY
				anchorPane.remove(button);
			});
		});
	}

	function testResize() {
		anchorPane.resize(180, 80);
		Assert.equals(180, anchorPane.layoutWidth);
		Assert.equals(80, anchorPane.layoutHeight);

		anchorPane.setPadding(10, 20, 30, 40); // Left, Right, Top, Bottom
		button.setPosition(20, 10);

		Style.withOverride(button.style.size, "minWidth", 20, () -> {
			Style.withOverride(button.style.size, "minHeight", 20, () -> {
				anchorPane.add(button, Anchor.TopLeft);
				anchorPane.resize(300, 200);
				Assert.equals(300 - 10 - 20 - 20, button.layoutWidth); // width - padding R/L - positionX
				Assert.equals(200 - 30 - 40 - 10, button.layoutHeight); // height - padding T/D - positionY
				anchorPane.remove(button);

				anchorPane.add(button, Anchor.MiddleCenter);
				anchorPane.resize(400, 300);
				Assert.equals(400 - 10 - 20 - 20, button.layoutWidth); // width - padding R/L - positionX
				Assert.equals(300 - 30 - 40 - 10, button.layoutHeight); // height - padding T/D - positionY
				anchorPane.remove(button);

				anchorPane.add(button, Anchor.BottomRight);
				anchorPane.resize(500, 400);
				Assert.equals(500 - 10 - 20 + 20, button.layoutWidth); // width - padding R/L + positionX
				Assert.equals(400 - 30 - 40 + 10, button.layoutHeight); // height - padding T/D + positionY
				anchorPane.remove(button);
			});
		});
	}

	@:depends(testAddRemove, testAnchorPoints, testResize)
	function testGetElementOnPosition() {
		button.setPosition(50, 30);
		button.setSize(20, 10);

		anchorPane.setSize(200, 100);
		anchorPane.setPosition(1000, 500);
		anchorPane.setPadding(0, 0, 0, 0);

		anchorPane.add(button, Anchor.TopLeft);

		// Over button
		Assert.equals(button, anchorPane.getElementAtPosition(1000 + 50 + 2, 500 + 30 + 2));

		// Not over button
		Assert.isNull(anchorPane.getElementAtPosition(1000 + 50 - 1, 500 + 30 - 1));
		Assert.isNull(anchorPane.getElementAtPosition(1000 + 50 + 21, 500 + 30 + 11));

		// Not over layout
		Assert.isNull(anchorPane.getElementAtPosition(900, 400));

		button.visible = false;
		Assert.isNull(anchorPane.getElementAtPosition(1000 + 50 + 1, 500 + 30 + 1));
		button.visible = true;

		anchorPane.absorbEvents = true;
		Assert.equals(anchorPane, anchorPane.getElementAtPosition(1000 + 50 + 1, 500 + 30 + 1));
	}
}
