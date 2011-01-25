package org.tbyrne.display.progress
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.ILayoutView;
	
	public interface IProgressDisplay
	{
		function set measurable(value:Boolean):void;
		function set message(value:String):void;
		function set progress(value:Number):void;
		function set total(value:Number):void;
		function set units(value:String):void;
		function get display():IDisplayObject;
		function get layoutView():ILayoutView;
	}
}