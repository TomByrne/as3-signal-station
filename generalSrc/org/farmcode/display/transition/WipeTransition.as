package org.farmcode.display.transition
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class WipeTransition extends Transition
	{
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		
		/**
		 * Whether the start DisplayObject slides with the wipe or stays stationary.
		 */
		public var slideStart:Boolean = false;
		/**
		 * Whether the finish DisplayObject slides with the wipe or stays stationary.
		 */
		public var slideFinish:Boolean = false;
		/**
		 * Determines the direction of the wipe, possible values are:
		 * <ul>
		 * 	<li>WipeTransition.UP</li>
		 * 	<li>WipeTransition.DOWN</li>
		 * 	<li>WipeTransition.LEFT</li>
		 * 	<li>WipeTransition.RIGHT</li>
		 * </ul>
		 */
		public var direction:String = LEFT;
		
		
		override public function doTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number, currentTime:Number):void{
			var dir:Number = (direction==UP || direction==LEFT?-1:1);
			var vert:Boolean = (direction==UP || direction==DOWN);
			
			var bitmapMatrix:Matrix = bitmap.transform.concatenatedMatrix;
			bitmapMatrix.invert();
			
			bitmap.bitmapData.fillRect(new Rectangle(0,0,bitmap.width,bitmap.height),0);
			var fraction:Number = currentTime/duration;
			var matrix:Matrix = start.transform.concatenatedMatrix;
			matrix.concat(bitmapMatrix);
			var clipRect:Rectangle;
			if(slideStart){
				if(vert){
					matrix.ty += bitmap.height*dir*fraction;
				}else{
					matrix.tx += bitmap.width*dir*fraction;
				}
			}else{
				if(vert){
					clipRect = new Rectangle(0,dir>0?bitmap.height*fraction:0,bitmap.width,bitmap.height*(1-fraction));
				}else{
					clipRect = new Rectangle(dir>0?bitmap.width*fraction:0,0,bitmap.width*(1-fraction),bitmap.height);
				}
			}
			bitmap.bitmapData.draw(start,matrix,start.transform.colorTransform,start.blendMode,clipRect);
			
			matrix = finish.transform.concatenatedMatrix;
			matrix.concat(bitmapMatrix);
			clipRect = null;
			if(slideFinish){
				if(vert){
					matrix.ty += bitmap.height*dir*(fraction-1);
				}else{
					matrix.tx += bitmap.width*dir*(fraction-1);
				}
			}else{
				if(vert){
					clipRect = new Rectangle(0,dir<0?bitmap.height*(1-fraction):0,bitmap.width,bitmap.height*fraction);
				}else{
					clipRect = new Rectangle(dir<0?bitmap.width*(1-fraction):0,0,bitmap.width*fraction,bitmap.height);
				}
			}
			bitmap.bitmapData.draw(finish,matrix,finish.transform.colorTransform,finish.blendMode,clipRect);
			
		}
	}
}