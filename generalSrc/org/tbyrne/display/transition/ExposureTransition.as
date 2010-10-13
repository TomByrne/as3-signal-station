package org.tbyrne.display.transition
{
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.assets.assetTypes.IBitmapAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	
	public class ExposureTransition extends Transition
	{
		public var overExpose:Boolean = true;
		
		public function ExposureTransition(overExpose:Boolean = true){
			this.overExpose = overExpose;
		}
		
		override public function doTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number, currentTime:Number):void{
			var fract:Number = currentTime/duration;
			var subject:IDisplayAsset;
			if(fract<=0.5){
				fract = fract/0.5;
				subject = start;
			}else{
				fract = (fract-1)/-0.5;
				subject = finish;
			}
			var selfBounds:Rectangle = subject.getBounds(subject);
			var bounds:Rectangle = subject.getBounds(bitmap);
			var matrix:Matrix = subject.transform.matrix;
			matrix.tx = bounds.x-selfBounds.x;
			matrix.ty = bounds.y-selfBounds.y;
			var color:ColorTransform = subject.transform.colorTransform;
			color.redMultiplier = 
			color.greenMultiplier = 
			color.blueMultiplier = 1+(overExpose?fract:-fract);
			color.redOffset = 
			color.greenOffset = 
			color.blueOffset = 0xff*(overExpose?fract:-fract);
			bitmap.bitmapData.draw(subject.bitmapDrawable,matrix,color);
		}
	}
}