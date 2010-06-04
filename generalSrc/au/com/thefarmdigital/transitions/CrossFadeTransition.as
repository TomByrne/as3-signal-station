package au.com.thefarmdigital.transitions
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class CrossFadeTransition extends Transition
	{
		override public function doTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number, currentTime:Number):void{
			var fract:Number = (currentTime/duration);
			var invFract:Number = 1-fract;
			
			var bounds:Rectangle = start.getBounds(bitmap.parent);
			var matrix:Matrix = start.transform.matrix;
			matrix.tx -= bounds.x;
			matrix.ty -= bounds.y;
			var color:ColorTransform = finish.transform.colorTransform;
			color.alphaMultiplier = (1+Math.cos(fract*fract*Math.PI))/2;
			bitmap.bitmapData.draw(start,matrix,color);
			
			bounds = finish.getBounds(bitmap);
			matrix = finish.transform.matrix;
			matrix.tx = bounds.x;
			matrix.ty = bounds.y;
			color = finish.transform.colorTransform;
			color.alphaMultiplier = (1+Math.cos(invFract*invFract*Math.PI))/2;
			bitmap.bitmapData.draw(finish,matrix,color);
		}
	}
}