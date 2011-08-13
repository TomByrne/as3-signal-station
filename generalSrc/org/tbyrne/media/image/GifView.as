package org.tbyrne.media.image
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import org.tbyrne.display.assets.nativeTypes.IBitmap;
	import org.tbyrne.display.assets.nativeTypes.ILoader;
	
	public class GifView extends ImageView
	{
		public function get isGif():Boolean{
			return _isGif;
		}
		public function set isGif(value:Boolean):void{
			if(_isGif!=value){
				_isGif = value;
				asset = (value?_bitmap:_loader);
			}
		}
		
		
		public function get bitmapData():BitmapData{
			return _bitmap.bitmapData;
		}
		public function set bitmapData(value:BitmapData):void{
			_bitmap.bitmapData = value;
		}
		
		private var _isGif:Boolean;
		
		private var _loader:ILoader;
		private var _bitmap:IBitmap;
		
		public function GifView(loader:ILoader, bitmap:IBitmap, measurements:Point, smoothing:Boolean)
		{
			_loader = loader;
			_bitmap = bitmap;
			super(loader, measurements, smoothing);
		}
		override protected function applySmoothing():void{
			super.applySmoothing();
			_bitmap.smoothing = smoothing;
		}
		public function dispose():void{
			_loader.unload();
			_loader = null;
			_bitmap.bitmapData = null;
			_bitmap = null;
			asset = null;
		}
	}
}