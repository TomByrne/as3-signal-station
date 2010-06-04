package org.farmcode.display.progress
{
	import flash.display.DisplayObject;
	
	public interface IProgressDisplay
	{
		function set measurable(value:Boolean):void;
		function set message(value:String):void;
		function set progress(value:Number):void;
		function set total(value:Number):void;
		function set units(value:String):void;
		function get display():DisplayObject;
	}
}