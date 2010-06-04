package org.farmcode.display.layout.core
{
	public interface IConstrainedLayoutInfo extends ILayoutInfo
	{
		function get minWidth():Number;
		function get minHeight():Number;
		function get maxWidth():Number;
		function get maxHeight():Number;
	}
}