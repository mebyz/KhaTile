package koui.effects;

import koui.elements.Element;

class Border extends Effect {
	#if (KOUI_EFFECTS_OFF || KOUI_EFFECTS_BORDER_OFF)
	public static inline function draw(g: kha.graphics2.Graphics, element: Element) {}

	#else
	@:access(koui.elements.Element)
	public static function draw(g: kha.graphics2.Graphics, element: Element) {
		var propertiesBorder = koui.theme.Style.getStyle(element.tID).border;

		if (propertiesBorder == null || propertiesBorder.size <= 0) return;

		var thickness = propertiesBorder.size;
		g.color = propertiesBorder.color;

		switch(propertiesBorder.style) {
			case "inset":
				g.drawRect(element.drawX + thickness/2, element.drawY + thickness/2,
					element.drawWidth - thickness, element.drawHeight - thickness, thickness);
			case "middle":
				g.drawRect(element.drawX, element.drawY, element.drawWidth, element.drawHeight, thickness);
			case "outset":
				g.drawRect(element.drawX - thickness/2, element.drawY - thickness/2,
					element.drawWidth + thickness, element.drawHeight + thickness, thickness);
			default:
				trace('Koui warning: Border style ${propertiesBorder.style} not supported!');
		}
	}
	#end
}
