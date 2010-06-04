package org.farmcode.display.assets.nativeAssets
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.farmcode.display.assets.IGraphicsAsset;
	
	public class GraphicsAsset extends Asset implements IGraphicsAsset
	{
		internal function get graphics():Graphics{
			return _graphics;
		}
		
		
		internal function set graphics(value:Graphics):void {
			if(_graphics!=value) {
				_graphics = value;
			}
		}
		
		private var _graphics:Graphics;
		
		
		public function GraphicsAsset(){
		}
		
		public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix=null, repeat:Boolean=true, smooth:Boolean=false):void{
			_graphics.beginBitmapFill(bitmap, matrix, repeat, smooth);
		}
		
		public function beginFill(color:uint, alpha:Number=1.0):void{
			_graphics.beginFill(color, alpha);
		}
		
		public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix=null, spreadMethod:String="pad", interpolationMethod:String="rgb", focalPointRatio:Number=0):void{
			_graphics.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
		}
		
		public function clear():void{
			_graphics.clear();
		}
		
		public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void{
			_graphics.curveTo(controlX, controlY, anchorX, anchorY);
		}
		
		public function drawCircle(x:Number, y:Number, radius:Number):void{
			_graphics.drawCircle(x, y, radius);
		}
		
		public function drawEllipse(x:Number, y:Number, width:Number, height:Number):void{
			_graphics.drawEllipse(x, y, width, height);
		}
		
		public function drawRect(x:Number, y:Number, width:Number, height:Number):void{
			_graphics.drawRect(x, y, width, height);
		}
		
		public function drawRoundRect(x:Number, y:Number, width:Number, height:Number, ellipseWidth:Number, ellipseHeight:Number=NaN):void{
			_graphics.drawRoundRect(x, y, width, height, ellipseWidth, ellipseHeight);
		}
		
		public function endFill():void{
			_graphics.endFill();
		}
		
		public function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix=null, spreadMethod:String="pad", interpolationMethod:String="rgb", focalPointRatio:Number=0):void{
			_graphics.lineGradientStyle(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
		}
		
		public function lineStyle(thickness:Number=NaN, color:uint=0, alpha:Number=1.0, pixelHinting:Boolean=false, scaleMode:String="normal", caps:String=null, joints:String=null, miterLimit:Number=3):void{
			_graphics.lineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
		}
		
		public function lineTo(x:Number, y:Number):void{
			_graphics.lineTo(x, y);
		}
		
		public function moveTo(x:Number, y:Number):void{
			_graphics.moveTo(x, y);
		}
	}
}