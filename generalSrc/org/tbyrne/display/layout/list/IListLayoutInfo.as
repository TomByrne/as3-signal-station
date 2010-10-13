package org.tbyrne.display.layout.list
{
	import org.tbyrne.display.layout.core.IMarginLayoutInfo;
	import org.tbyrne.display.layout.core.ILayoutInfo;
	
	public interface IListLayoutInfo extends ILayoutInfo
	{
		function get listIndex():int;
	}
}