package org.tbyrne.media.image
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.assets.nativeTypes.IBitmap;
	import org.tbyrne.display.assets.nativeTypes.ILoader;
	import org.tbyrne.media.MediaView;
	
	public class ImageView extends MediaView
	{
		
		public function get smoothing():Boolean{
			return _smoothing;
		}
		public function set smoothing(value:Boolean):void{
			if(_smoothing!=value){
				_smoothing = value;
				applySmoothing();
			}
		}
		
		private var _smoothing:Boolean;
		
		public function ImageView(asset:ILoader, measurements:Point, smoothing:Boolean){
			super(asset, measurements);
			asset.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			this.smoothing = smoothing;
		}
		protected function onLoaderComplete(e:Event):void{
			invalidateSize();
			applySmoothing();
		}
		protected function applySmoothing():void{
			var loader:ILoader = (asset as ILoader);
			var bitmap:IBitmap = (loader.content as IBitmap);
			if(bitmap){
				bitmap.smoothing = smoothing;
			}
		}
	}
}