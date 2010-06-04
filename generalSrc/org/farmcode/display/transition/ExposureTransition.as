package org.farmcode.display.transition
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class ExposureTransition extends Transition
	{
		public var overExpose:Boolean = true;
		
		public function ExposureTransition(overExpose:Boolean = true){
			this.overExpose = overExpose;
		}
		
		override public function doTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number, currentTime:Number):void{
			var fract:Number = currentTime/duration;
			var subject:DisplayObject;
			if(fract<=0.5){
				fract = fract/0.5;
				subject = start;
			}else{
				fract = (fract-1)/-0.5;
				subject = finish;
			}
			var selfBounds:Rectangle = subject.getRect(subject);
			var bounds:Rectangle = subject.getRect(bitmap);
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
			bitmap.bitmapData.draw(subject,matrix,color);
		}
	}
}