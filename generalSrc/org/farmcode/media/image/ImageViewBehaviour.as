package org.farmcode.media.image
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.farmcode.media.MediaViewBehaviour;
	
	public class ImageViewBehaviour extends MediaViewBehaviour
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
		
		public function ImageViewBehaviour(asset:Loader, displayMeasurements:Rectangle, smoothing:Boolean){
			super(asset, displayMeasurements);
			asset.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			this.smoothing = smoothing;
		}
		protected function onLoaderComplete(e:Event):void{
			invalidate();
			applySmoothing();
		}
		protected function applySmoothing():void{
			var loader:Loader = (asset as Loader);
			var bitmap:Bitmap = (loader.content as Bitmap);
			if(bitmap){
				bitmap.smoothing = smoothing;
			}
		}
	}
}