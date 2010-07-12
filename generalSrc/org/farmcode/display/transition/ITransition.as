package org.farmcode.display.transition
{
	import org.farmcode.display.assets.IBitmapAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	
	public interface ITransition
	{
		
		function set timing(value:String):void;
		function get timing():String;
		function set duration(value:Number):void;
		function get duration():Number;
		
		function beginTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void;
		function doTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number, currentTime:Number):void;
		function endTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void;
	}
}