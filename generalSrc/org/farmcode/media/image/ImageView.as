package org.farmcode.media.image
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IBitmapAsset;
	import org.farmcode.display.assets.ILoaderAsset;
	import org.farmcode.media.MediaView;
	
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
		
		public function ImageView(asset:ILoaderAsset, displayMeasurements:Rectangle, smoothing:Boolean){
			super(asset, displayMeasurements);
			asset.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			this.smoothing = smoothing;
		}
		protected function onLoaderComplete(e:Event):void{
			invalidate();
			applySmoothing();
		}
		protected function applySmoothing():void{
			var loader:ILoaderAsset = (asset as ILoaderAsset);
			var bitmap:IBitmapAsset = (loader.content as IBitmapAsset);
			if(bitmap){
				bitmap.smoothing = smoothing;
			}
		}
	}
}