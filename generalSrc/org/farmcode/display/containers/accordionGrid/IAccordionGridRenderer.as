package org.farmcode.display.containers.accordionGrid
{
	import org.farmcode.display.containers.accordion.IAccordionRenderer;
	import org.farmcode.display.core.ILayoutView;

	public interface IAccordionGridRenderer extends IAccordionRenderer{
		function addCellRenderer(cellRenderer:ILayoutView, headerCell:Boolean):void;
		function removeCellRenderer(cellRenderer:ILayoutView):void;
	}
}