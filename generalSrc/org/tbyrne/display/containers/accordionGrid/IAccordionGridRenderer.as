package org.tbyrne.display.containers.accordionGrid
{
	import org.tbyrne.display.containers.accordion.IAccordionRenderer;
	import org.tbyrne.display.core.ILayoutView;

	public interface IAccordionGridRenderer extends IAccordionRenderer{
		function addCellRenderer(cellRenderer:ILayoutView, headerCell:Boolean):void;
		function removeCellRenderer(cellRenderer:ILayoutView):void;
	}
}