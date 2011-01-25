package org.tbyrne.display.transition
{
	import org.tbyrne.display.assets.nativeTypes.IBitmap;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	public interface ITransition
	{
		
		function set timing(value:String):void;
		function get timing():String;
		function set duration(value:Number):void;
		function get duration():Number;
		
		function beginTransition(start:IDisplayObject, finish:IDisplayObject, bitmap:IBitmap, duration:Number):void;
		function doTransition(start:IDisplayObject, finish:IDisplayObject, bitmap:IBitmap, duration:Number, currentTime:Number):void;
		function endTransition(start:IDisplayObject, finish:IDisplayObject, bitmap:IBitmap, duration:Number):void;
	}
}