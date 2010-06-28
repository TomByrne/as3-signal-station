package org.farmcode.display.layout.grid
{
	import org.farmcode.display.layout.ILayoutSubject;
	
	/**
	 * This interface is optional and gives the renderer access
	 * to it's coordinates within the grid.
	 */
	public interface IGridLayoutSubject extends ILayoutSubject
	{
		function set columnIndex(value:int):void;
		function set rowIndex(value:int):void;
	}
}