package au.com.thefarmdigital.transitions
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	public class BlurTransition extends Transition
	{
		public function get blurQuality():int{
			return _blurFilter.quality;
		}
		public function set blurQuality(value:int):void{
			_blurFilter.quality = value;
		}
		
		
		public function get blurX():Number{
			return _blurX;
		}
		public function set blurX(value:Number):void{
			_blurX = value;
		}
		
		
		public function get blurY():Number{
			return _blurY;
		}
		public function set blurY(value:Number):void{
			_blurY = value;
		}
		
		private var _blurX:Number = 4;
		private var _blurY:Number = 4;
		private var _blurFilter:BlurFilter = new BlurFilter();
		
		override public function doTransition(start:DisplayObject, finish:DisplayObject, bitmap:Bitmap, duration:Number, currentTime:Number):void{
			var fract:Number = currentTime/duration;
			if(fract<=0.5){
				fract = fract/0.5;
			}else{
				fract = (fract-1)/-0.5;
			}
			
			_blurFilter.blurX = fract*_blurX;
			_blurFilter.blurY = fract*_blurY;
			
			bitmap.bitmapData.applyFilter(bitmap.bitmapData,bitmap.bitmapData.rect,new Point(),_blurFilter);
		}
	}
}