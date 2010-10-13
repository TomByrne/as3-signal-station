package org.tbyrne.display.layout.grid
{
	import org.tbyrne.display.layout.core.ILayoutInfo;

	public interface IGridLayoutInfo extends ILayoutInfo
	{
		function get columnIndex():int;
		function get rowIndex():int;
	}
}