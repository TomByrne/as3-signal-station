package org.farmcode.display.assets
{
	import flash.display.BitmapData;

	public interface IBitmapAsset extends IDisplayAsset
	{
		function get bitmapData():BitmapData;
		function set bitmapData(value:BitmapData):void;
		function get pixelSnapping():String;
		function set pixelSnapping(value:String):void;
		function get smoothing():Boolean;
		function set smoothing(value:Boolean):void;
	}
}