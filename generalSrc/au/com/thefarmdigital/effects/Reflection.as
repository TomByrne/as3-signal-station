package au.com.thefarmdigital.effects {
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IDisplayAsset;
	
	/**
	 * The Reflection class can be used to create a reflection under a DisplayObject.
	 */
	public class Reflection extends AnimatedEffect {
		private static var MAX_DIMENSION:Number = 2880;
		
		public function set height(to:Number):void 
		{ 
			if(_height !=to && !isNaN(to)) {
				_height = to;
				invalidate();
			}
		}
		public function get height():Number {
			return _height;
		}
		
		public function set reflectionScale(to:Number):void {
			if(super.amount !=to && !isNaN(to)) {
				super.amount = to;
				invalidate();
			}
		}		
		public function get reflectionScale():Number {
			return super.amount;
		}
		override protected function get subjectBounds():Rectangle {
			return super.subjectBounds;
		}
		override protected function set subjectBounds(value:Rectangle):void {
			super.subjectBounds = value;
			_renderOffset.y = value.height;
		}
		

		private var _height					: Number;
		private var _subjectSelfBounds		: Rectangle;
		private var _reflectionBitmapData	: BitmapData;
		
		// added default parameter values (so an empty constructor can be used)
		public function Reflection (subject:IDisplayAsset=null, height:Number=NaN) {
			super(subject);
			this.height = height;
			reflectionScale = 1;
		}
		override public function remove():void{
			super.remove();
			_reflectionBitmapData = null;
		}
		
		override protected function createBitmap():void {
			if(subject && subject.stage && renderArea.stage){
				_subjectSelfBounds = subject.getBounds(subject);
				subjectBounds = subject.getBounds(renderArea.parent);
				
				// use the _height property only if it is set
				var actualHeight:Number = Math.min((isNaN(_height)?Math.ceil(subjectBounds.height):_height),MAX_DIMENSION);
				var actualWidth:Number = Math.min(Math.ceil(subjectBounds.width),MAX_DIMENSION);
				
				if(actualWidth && actualHeight){
					if(_reflectionBitmapData)_reflectionBitmapData.dispose();
					_reflectionBitmapData = new BitmapData(actualWidth, actualHeight, true, 0);
					_reflectionBitmapData.lock();
					
					// use the subject's colorTransform, matrix and blendMode to retain the actual look of the subject
					// do flip via matrix
					var drawMatrix:Matrix = subject.transform.matrix;
					drawMatrix.tx = -_subjectSelfBounds.x;
					drawMatrix.ty = ((_subjectSelfBounds.height*drawMatrix.d)*reflectionScale)+_subjectSelfBounds.y;
					drawMatrix.d *= -reflectionScale;
					drawMatrix.b *= -1;
					var wasVisible:Boolean = renderArea.visible;
					renderArea.visible = false;
					_reflectionBitmapData.draw(subject.bitmapDrawable,drawMatrix/*,subject.transform.colorTransform,subject.blendMode*/);
					renderArea.visible = wasVisible;
					
					// create a shape and fill it with the gradient that we want to use for our reflection
					var alphaShape:Shape = new Shape();
					var alphaMatrix:Matrix = new Matrix();
					alphaMatrix.createGradientBox(actualWidth,actualHeight,90*(Math.PI/180));
					alphaShape.graphics.beginGradientFill(GradientType.LINEAR,[0xffffff,0],[100,100],[0,0xff],alphaMatrix);
					alphaShape.graphics.drawRect(0,0,actualWidth,actualHeight);
					
					// draw the alphaShape into another BitmapData and then copy the alpha channel of the new bitmapData into the _reflectionBitmapData
					var copyRect:Rectangle = new Rectangle(0,0,actualWidth,actualHeight);
					var copyPoint:Point = new Point(0,0);
					if(alphaBitmapData)alphaBitmapData.dispose();
					var alphaBitmapData:BitmapData = new BitmapData(actualWidth,actualHeight,false,0);
					alphaBitmapData.copyChannel(_reflectionBitmapData,copyRect,copyPoint,BitmapDataChannel.ALPHA,BitmapDataChannel.BLUE);
					alphaBitmapData.draw(alphaShape,null,null,BlendMode.MULTIPLY);
					_reflectionBitmapData.copyChannel(alphaBitmapData,copyRect,copyPoint,BitmapDataChannel.BLUE,BitmapDataChannel.ALPHA);
					
					// display it
					renderArea.bitmapData = _reflectionBitmapData;
					_reflectionBitmapData.unlock();
					_bitmapChanged = false;
				}else{
					if(renderArea.bitmapData)renderArea.bitmapData.dispose();
					renderArea.bitmapData = new BitmapData(1,1,true,0);
				}
			}
		}
	}	
}