package org.tbyrne.display.transition
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.assets.assetTypes.IBitmapAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	
	/**
	 * The ShutterTransition mimics the rotating shutters of some billboards.
	 */
	public class ShutterTransition extends Transition
	{
		// Directions
		public static const VERTICAL:String = "vertical";
		public static const HORIZONTAL:String = "horizontal";
		
		// Shutter Directions
		public static const FORWARDS:String = "forwards";
		public static const BACKWARDS:String = "backwards";
		public static const TO_CENTER:String = "toCenter";
		public static const FROM_CENTER:String = "fromCenter";
		
		public var shutterSize:Number = 10;
		public var direction:String = HORIZONTAL;
		public var shutterDirection:String = FORWARDS;
		public var shutterDelay:Number = 0; // between 0 and 1
		public var tilt:Number = 0;// between -1 and 1
		
		public var forwardFacingAlpha:Number = 0;
		public var forwardFacingColor:Number = 0xffffff;
		public var backwardFacingAlpha:Number = 0;
		public var backwardFacingColor:Number = 0;
		
		private var shutters:Array;
		
		public function ShutterTransition(direction:String=HORIZONTAL, shutterDirection:String=FORWARDS){
			if(direction)this.direction = direction;
			if(shutterDirection)this.shutterDirection = shutterDirection;
		}
		
		override public function beginTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void{
			shutters = [];
			var ver:Boolean = direction==VERTICAL;
			var totalSize:Number = (ver?bitmap.width:bitmap.height);
			var shutterSpan:Number = (ver?bitmap.height:bitmap.width);
			var totalShutters:Number = Math.ceil(totalSize/shutterSize);
			var forw:Boolean = shutterDirection==FORWARDS;
			var toCe:Boolean = shutterDirection==TO_CENTER;
			var frCe:Boolean = shutterDirection==FROM_CENTER;
			var offset:Number = totalSize-(totalShutters*shutterSize);
			for(var i:int=0; i<totalShutters; ++i){
				var shutter:Shutter = new Shutter();
				var pos:Number = (i*shutterSize)+offset;
				shutter.direction = (forw || (toCe && i<totalShutters/2) || (frCe && i>totalShutters/2));
				shutter.rect = new Rectangle(ver?pos:0,ver?0:pos,ver?shutterSize:shutterSpan,ver?shutterSpan:shutterSize);
				shutters.push(shutter);
			}
		}
		override public function doTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number, currentTime:Number):void{
			var bitmapMatrix:Matrix = bitmap.transform.concatenatedMatrix;
			bitmapMatrix.invert();
			
			bitmap.bitmapData.fillRect(new Rectangle(0,0,bitmap.bitmapData.width,bitmap.bitmapData.height),0);
			var ver:Boolean = direction==VERTICAL;
			var fract:Number = currentTime/duration;
			
			var forw:Boolean = shutterDirection==FORWARDS;
			var toCe:Boolean = shutterDirection==TO_CENTER;
			var frCe:Boolean = shutterDirection==FROM_CENTER;
			var fractPerShutter:Number = 1/((shutters.length*shutterDelay)+(1-shutterDelay));
			var length:int = shutters.length;
			
			for(var i:int=0; i<length; ++i){
				var shutter:Shutter = shutters[i];
				var order:Number;
				if(forw){
					order = i/(shutters.length*(1+fractPerShutter));
				}else if(toCe){
					order = Math.min(i,shutters.length-1-i)/((shutters.length/2)*(1+fractPerShutter));
				}else if(frCe){
					order = (Math.max(i,shutters.length-1-i)/((shutters.length/2)*(1+fractPerShutter)))-1;
				}else{
					order = (shutters.length-1-i)/(shutters.length*(1+fractPerShutter));
				}
				var pos:Number = (((fract-order)/fractPerShutter)*shutterDelay)+(fract*(1-shutterDelay));
				pos = shutter.direction?1-pos:pos;
				pos = Math.max(Math.min(pos,1),0);
				var subject:IDisplayAsset = shutter.direction?finish:start;
				var rect:Rectangle = shutter.rect.clone();
				var matrix:Matrix = subject.transform.concatenatedMatrix;
				matrix.concat(bitmapMatrix);
				var angle:Number = Math.tan(Math.PI/4*tilt*pos);
				if(ver){
					matrix.b = angle*matrix.d;
					rect.width *= 1-pos;
					matrix.a *= 1-pos;
					matrix.tx *= (1-pos);
					matrix.tx += shutter.rect.x*pos;
					matrix.ty -= (bitmap.width*(rect.x/bitmap.width)*angle);
				}else{
					matrix.c = angle*matrix.a;
					rect.height *= 1-pos;
					matrix.d *= 1-pos;
					matrix.ty *= (1-pos);
					matrix.ty += shutter.rect.y*pos;
					matrix.tx -= (bitmap.height*(rect.y/bitmap.height)*angle);
				}
				var color:ColorTransform = subject.transform.colorTransform;
				transformColor(color,backwardFacingColor,backwardFacingAlpha,pos);
				bitmap.bitmapData.draw(subject.bitmapDrawable,matrix,color,null,rect,true);
				
				// aft object
				subject = shutter.direction?start:finish;
				rect = shutter.rect.clone();
				matrix = subject.transform.concatenatedMatrix;
				matrix.concat(bitmapMatrix);
				angle = Math.tan(-Math.PI/4*tilt*(1-pos));
				if(ver){
					rect.width *= pos;
					rect.x += shutter.rect.width*(1-pos);
					matrix.a *= pos;
					matrix.tx *= pos;
					matrix.tx += shutter.rect.x*(1-pos)+(shutter.rect.width*(1-pos));
					matrix.ty -= (bitmap.width*(rect.x/bitmap.width)*angle);
					matrix.b = angle*matrix.d;
				}else{
					rect.height *= pos;
					rect.y += shutter.rect.height*(1-pos);
					matrix.d *= pos;
					matrix.ty *= pos;
					matrix.ty += shutter.rect.y*(1-pos)+(shutter.rect.height*(1-pos));
					matrix.tx -= (bitmap.height*(rect.y/bitmap.height)*angle);
					matrix.c = angle*matrix.a;
				}
				color = subject.transform.colorTransform;
				transformColor(color,forwardFacingColor,forwardFacingAlpha,1-pos);
				bitmap.bitmapData.draw(subject.bitmapDrawable,matrix,color,null,rect,true);
			}
		}
		override public function endTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void{
		}
		
		private function transformColor(colorTrans:ColorTransform, color:Number, alpha:Number, pos:Number):void{
			var red:Number = ((color & 0xff0000)>>16);
			var green:Number = ((color & 0xff00)>>8);
			var blue:Number = (color & 0xff);
			colorTrans.redOffset += (red*alpha*pos*2)-0xff*pos;
			colorTrans.greenOffset += (green*alpha*pos*2)-0xff*pos;
			colorTrans.blueOffset += (blue*alpha*pos*2)-0xff*pos;
		}
	}
}
import flash.geom.Rectangle;
	
class Shutter{
	public var rect:Rectangle;
	public var direction:Boolean;
}