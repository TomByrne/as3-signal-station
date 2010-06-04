package org.farmcode.display.transition
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	public interface ITransition
	{
		
		function set timing(value:String):void;
		function get timing():String;
		function set duration(value:Number):void;
		function get duration():Number;
		
		function beginTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number):void;
		function doTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number, currentTime:Number):void;
		function endTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number):void;
	}
}