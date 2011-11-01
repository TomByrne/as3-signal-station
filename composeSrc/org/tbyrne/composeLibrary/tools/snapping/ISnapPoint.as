package org.tbyrne.composeLibrary.tools.snapping
{
	public interface ISnapPoint
	{
		function get snappingGroup():String;
		function get offsetX():Number;
		function get offsetY():Number;
		function get offsetZ():Number;
		
		function get x2d():Number;
		function get y2d():Number;
	}
}