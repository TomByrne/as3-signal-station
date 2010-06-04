package org.farmcode.display.transition
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class BlurTransition extends Transition
	{
		public function get blurQuality():int{
			return _blurFilter.quality;
		}
		public function set blurQuality(value:int):void{
			_blurFilter.quality = value;
		}
		
		public var blurX:Number = 4;
		public var blurY:Number = 4;
		private var _blurFilter:BlurFilter = new BlurFilter();
		
		public function BlurTransition(blurX:Number=4, blurY:Number=4){
			this.blurX = blurX;
			this.blurY = blurY;
		}
		
		override public function doTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number, currentTime:Number):void{
			var bitmapMatrix:Matrix = bitmap.transform.concatenatedMatrix;
			bitmapMatrix.invert();
			
			var fract:Number = currentTime/duration;
			var subject:DisplayObject;
			if(fract<=0.5){
				fract = (fract)/0.5;
				subject = start;
			}else{
				fract = (fract-1)/-0.5;
				subject = finish;
			}
			
			
			var matrix:Matrix = subject.transform.concatenatedMatrix;
			matrix.concat(bitmapMatrix);
			
			_blurFilter.blurX = fract*blurX;
			_blurFilter.blurY = fract*blurY;
			
			var colorTrans:ColorTransform = subject.transform.colorTransform;
			colorTrans.alphaMultiplier = 1-fract;
			
			bitmap.bitmapData.draw(subject,matrix,colorTrans,subject.blendMode);
			bitmap.bitmapData.applyFilter(bitmap.bitmapData,bitmap.bitmapData.rect,new Point(),_blurFilter);
		}
	}
}