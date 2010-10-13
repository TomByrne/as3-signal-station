package org.tbyrne.display.progress
{
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.ILayoutView;
	
	public interface IProgressDisplay
	{
		function set measurable(value:Boolean):void;
		function set message(value:String):void;
		function set progress(value:Number):void;
		function set total(value:Number):void;
		function set units(value:String):void;
		function get display():IDisplayAsset;
		function get layoutView():ILayoutView;
	}
}