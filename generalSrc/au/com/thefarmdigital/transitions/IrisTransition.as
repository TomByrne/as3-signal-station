package au.com.thefarmdigital.transitions
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
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
		
		private var bundles:Dictionary = new Dictionary();
		
		override public function beginTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number):void{
			var bundle:BitmapBundle = new BitmapBundle();
			bundle.drawArea = new BitmapData(bitmap.width,bitmap.height,true,0);
			if(direction==OUT){
				bundle.maskBitmapData = new BitmapData(bitmap.width,bitmap.height,false,0);
				bundle.alphaBitmapData = new BitmapData(bitmap.width,bitmap.height,false,0);
			}
			bundles[start] = bundle;
		}
		override public function doTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, 
			duration:Number, currentTime:Number):void
		{
			var bundle:BitmapBundle = bundles[start];
			var offset:Point = start.globalToLocal(bitmap.localToGlobal(new Point()));
			var matrix:Matrix = start.transform.matrix;
			matrix.tx = offset.x;
			matrix.ty = offset.y;
			bitmap.bitmapData.draw(start,matrix,start.transform.colorTransform,start.blendMode);
			
			var sizeFract:Number = (direction==OUT?currentTime:duration-currentTime)/duration;
			var radius:Number = Math.sqrt(Math.pow(bitmap.width,2)+Math.pow(bitmap.height,2));
			CIRCLE_MASK.width = CIRCLE_MASK.height = radius*sizeFract;
			CIRCLE_MASK.x = bitmap.width/2;
			CIRCLE_MASK.y = bitmap.height/2;
			
			offset = finish.globalToLocal(bitmap.localToGlobal(new Point()));
			
			matrix = finish.transform.matrix;
			matrix.tx = offset.x;
			matrix.ty = offset.y;
			bundle.drawArea.draw(finish,matrix,null,null);
			if(direction==OUT){
				bundle.maskBitmapData.draw(CIRCLE_MASK,CIRCLE_MASK.transform.matrix,null);
				
				bundle.alphaBitmapData.copyChannel(bundle.drawArea,bundle.drawArea.rect,new Point(),BitmapDataChannel.ALPHA,BitmapDataChannel.RED);
				bundle.alphaBitmapData.draw(bundle.maskBitmapData,null,null,BlendMode.MULTIPLY);
				bundle.drawArea.copyChannel(bundle.alphaBitmapData,new Rectangle(0,0,bundle.alphaBitmapData.width,bundle.alphaBitmapData.height),new Point(0,0),BitmapDataChannel.RED,BitmapDataChannel.ALPHA);
				
			}else{
				bundle.drawArea.draw(CIRCLE_MASK,CIRCLE_MASK.transform.matrix,null,BlendMode.ERASE);
			}
			bitmap.bitmapData.draw(bundle.drawArea,null,finish.transform.colorTransform);
		}
		override public function endTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number):void{
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