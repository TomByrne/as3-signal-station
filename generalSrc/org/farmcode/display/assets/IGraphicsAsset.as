package org.farmcode.display.assets
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public interface IGraphicsAsset extends IAsset
	{
		function beginBitmapFill(bitmap:BitmapData, matrix:Matrix  = null, repeat:Boolean  = true, smooth:Boolean  = false):void;
		function beginFill(color:uint, alpha:Number = 1.0):void
		function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void;
		function clear():void;
		function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void;
		function drawCircle(x:Number, y:Number, radius:Number):void;
		function drawEllipse(x:Number, y:Number, width:Number, height:Number):void;
		function drawRect(x:Number, y:Number, width:Number, height:Number):void;
		function drawRoundRect(x:Number, y:Number, width:Number, height:Number, ellipseWidth:Number, ellipseHeight:Number = NaN):void;
		function endFill():void;
		function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix  = null, spreadMethod:String  = "pad", interpolationMethod:String  = "rgb", focalPointRatio:Number  = 0):void;
		function lineStyle(thickness:Number  = NaN, color:uint  = 0, alpha:Number  = 1.0, pixelHinting:Boolean  = false, scaleMode:String  = "normal", caps:String  = null, joints:String  = null, miterLimit:Number  = 3):void;
		function lineTo(x:Number, y:Number):void;
		function moveTo(x:Number, y:Number):void;
	}
}