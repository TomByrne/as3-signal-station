package org.tbyrne.display.layout.canvas
{
	import org.tbyrne.display.layout.core.ILayoutInfo;
	
	public interface ICanvasLayoutInfo extends ILayoutInfo
	{
		function get top():Number;
		function get bottom():Number;
		function get middle():Number;
		function get left():Number;
		function get right():Number;
		function get centre():Number;
		
		function get width():Number;
		function get height():Number;
		
		function get percentWidth():Number;
		function get percentHeight():Number;
	}
}