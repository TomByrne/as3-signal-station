package au.com.thefarmdigital.display.controls
{
	import flash.display.DisplayObject;

	public interface IControl
	{
		function get display():DisplayObject;
		function get measuredWidth():Number;
		function get measuredHeight():Number;
		function set visible(value:Boolean):void;
		
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
		function get width():Number;
		function set width(value:Number):void;
		function get height():Number;
		function set height(value:Number):void;
	}
}