package org.farmcode.display.layout.grid
{
	import org.farmcode.display.layout.core.ILayoutInfo;

	public interface IGridLayoutInfo extends ILayoutInfo
	{
		function get columnIndex():int;
		function get rowIndex():int;
	}
}