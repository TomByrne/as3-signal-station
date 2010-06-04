package au.com.thefarmdigital.display
{
	import au.com.thefarmdigital.structs.ImageData;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ImageView extends MediaView
	{
		public function get imageData():ImageData{
			return _imageData;
		}
		public function set imageData(value:ImageData):void{
			if(_imageData!=value){
				clearImageData();
				_imageData = value;
				_media = null;
				
				if(value){
					_media = value.loader;
					if(_media.parent)_media.parent.removeChild(_media);
					addChild(_media);
					value.addEventListener(Event.COMPLETE,eventInvalidate);
				}
				invalidate();
			}
		}
		private var _imageData:ImageData;
		
		public function ImageView(){
		}
		override protected function mediaLoaded():Boolean{
			return (_imageData?_imageData.loaded:false);
		}
		override protected function getMediaDimensions():Rectangle{
			return (_imageData && !isNaN(_imageData.imageHeight) && !isNaN(_imageData.imageWidth)?new Rectangle(0,0,_imageData.imageWidth,_imageData.imageHeight):null);
		}
		protected function clearImageData():void{
			if(_imageData){
				_imageData.removeEventListener(Event.COMPLETE,eventInvalidate);
				_imageData = null;
			}
			if(_media && contains(_media)){
				removeChild(_media);
			}
		}
	}
}