package org.tbyrne.display.transition
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.assetTypes.IBitmapAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	
	public class IrisTransition extends Transition
	{
		private static var CIRCLE_MASK:Sprite;
		{
			CIRCLE_MASK = new Sprite();
			CIRCLE_MASK.graphics.beginFill(0xffffff);
			CIRCLE_MASK.graphics.drawCircle(0,0,100)
		}
		
		public static const IN:String = "in";
		public static const OUT:String = "out";
		
		public var direction:String = OUT;
		public var reflect:Boolean = false;
		
		private var bundles:Dictionary = new Dictionary();
		
		public function IrisTransition(direction:String=OUT, reflect:Boolean = false){
			if(direction)this.direction = direction;
			this.reflect = reflect;
		}
		
		override public function beginTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void{
			var bundle:BitmapBundle = new BitmapBundle();
			bundle.drawArea = new BitmapData(bitmap.width,bitmap.height,true,0);
			bundle.maskBitmapData = new BitmapData(bitmap.width,bitmap.height,false,0);
			bundle.alphaBitmapData = new BitmapData(bitmap.width,bitmap.height,false,0);
			bundles[start] = bundle;
		}
		override public function doTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number, currentTime:Number):void{
			
			var bitmapMatrix:Matrix = bitmap.transform.concatenatedMatrix;
			bitmapMatrix.invert();
			
			var bundle:BitmapBundle = bundles[start];
			
			var innerSizeFract:Number;
			var outerSizeFract:Number;
			var innerSubject:IDisplayAsset;
			var outerSubject:IDisplayAsset;
			if(direction==OUT){
				innerSizeFract = currentTime/duration;
				innerSubject = start;
				outerSubject = finish;
			}else{
				innerSizeFract = (duration-currentTime)/duration;
				innerSubject = finish;
				outerSubject = start;
			}
			if(reflect){
				innerSizeFract = (innerSizeFract<0.5)?innerSizeFract*2:1;
				outerSizeFract = (innerSizeFract>0.5)?(innerSizeFract-0.5)*2:0;
			}else{
				outerSizeFract = innerSizeFract;
			}
			
			var radius:Number = Math.sqrt(Math.pow(bitmap.width,2)+Math.pow(bitmap.height,2));
			CIRCLE_MASK.width = CIRCLE_MASK.height = radius*innerSizeFract;
			CIRCLE_MASK.x = bitmap.width/2;
			CIRCLE_MASK.y = bitmap.height/2;
			
			var matrix:Matrix = innerSubject.transform.concatenatedMatrix;
			matrix.concat(bitmapMatrix);
			bitmap.bitmapData.draw(innerSubject.bitmapDrawable,matrix,innerSubject.transform.colorTransform,innerSubject.blendMode);
			bitmap.bitmapData.draw(CIRCLE_MASK,CIRCLE_MASK.transform.matrix,null,BlendMode.ERASE);
			
			if(outerSizeFract!=innerSizeFract){
				CIRCLE_MASK.width = CIRCLE_MASK.height = radius*outerSizeFract;
			}
			
			matrix = outerSubject.transform.concatenatedMatrix;
			matrix.concat(bitmapMatrix);
			bundle.drawArea.draw(outerSubject.bitmapDrawable,matrix,null,null);
			
			bundle.maskBitmapData.fillRect(bundle.maskBitmapData.rect,0);
			bundle.maskBitmapData.draw(CIRCLE_MASK,CIRCLE_MASK.transform.matrix,null);
			
			bundle.alphaBitmapData.copyChannel(bundle.drawArea,bundle.drawArea.rect,new Point(),BitmapDataChannel.ALPHA,BitmapDataChannel.RED);
			bundle.alphaBitmapData.draw(bundle.maskBitmapData,null,null,BlendMode.MULTIPLY);
			bundle.drawArea.copyChannel(bundle.alphaBitmapData,new Rectangle(0,0,bundle.alphaBitmapData.width,bundle.alphaBitmapData.height),new Point(0,0),BitmapDataChannel.RED,BitmapDataChannel.ALPHA);
				
			bitmap.bitmapData.draw(bundle.drawArea,null,finish.transform.colorTransform);
		}
		override public function endTransition(start:IDisplayAsset, finish:IDisplayAsset, bitmap:IBitmapAsset, duration:Number):void{
			var bundle:BitmapBundle = bundles[start];
			bundle.drawArea.dispose();
			bundle.maskBitmapData.dispose();
			bundle.alphaBitmapData.dispose();
			delete bundles[start];
		}
	}
}
import flash.display.BitmapData;
	
class BitmapBundle{
	public var drawArea:BitmapData;
	public var maskBitmapData:BitmapData;
	public var alphaBitmapData:BitmapData;
}