package org.tbyrne.display.assets.nativeTypes
{
	import flash.display.BitmapData;

	public interface IBitmap extends IDisplayObject
	{
		function get bitmapData():BitmapData;
		function set bitmapData(value:BitmapData):void;
		function get bitmapPixelSnapping():String;
		function set bitmapPixelSnapping(value:String):void;
		function get smoothing():Boolean;
		function set smoothing(value:Boolean):void;
	}
}