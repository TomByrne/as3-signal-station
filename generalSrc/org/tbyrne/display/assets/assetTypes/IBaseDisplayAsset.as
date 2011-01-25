package org.tbyrne.display.assets.assetTypes
{
	import org.tbyrne.display.assets.nativeTypes.IStage;

	public interface IBaseDisplayAsset extends IAsset
	{
		
		function set x(value:Number):void;
		function get x():Number;
		
		function set y(value:Number):void;
		function get y():Number;
		
		function set width(value:Number):void;
		function get width():Number;
		
		function set height(value:Number):void;
		function get height():Number;
		
		function get stage():IStage;
		
		function set visible(value:Boolean):void;
		function get visible():Boolean;
	}
}