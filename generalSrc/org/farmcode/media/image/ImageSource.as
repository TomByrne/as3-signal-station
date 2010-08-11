package org.farmcode.media.image
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.ILoaderAsset;
	import org.farmcode.display.assets.nativeAssets.LoaderAsset;
	import org.farmcode.display.assets.nativeAssets.NativeAssetFactory;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.layout.frame.FrameLayoutInfo;
	import org.farmcode.math.UnitConversion;
	import org.farmcode.media.MediaSource;
	import org.farmcode.media.MediaView;
	
	public class ImageSource extends MediaSource
	{
		private static const LOAD_UNITS:String = "Kb";
		
		public function get imageUrl():String{
			return _imageUrl;
		}
		public function set imageUrl(value:String):void{
			if(_imageUrl!=value){
				if(_imageUrl && _loadStarted){
					_urlLoader.close();
					for(var i:* in _allMediaDisplays){
						var view:MediaView = (i as MediaView);
						var loader:Loader = (view.asset as Loader);
						loader.unload();
					}
				}
				_imageUrl = value;
				_loadStarted = false;
				if(_imageUrl && _displaysTaken>0){
					_loadStarted = true;
					_urlLoader.load(new URLRequest(imageUrl));
				}
			}
		}
		public function get smoothing():Boolean{
			return _smoothing;
		}
		public function set smoothing(value:Boolean):void{
			if(_smoothing!=value){
				_smoothing = value;
				for(var i:* in _allMediaDisplays){
					var view:ImageView = (i as ImageView);
					view.smoothing = value;
				}
			}
		}
		
		override public function get loadUnits():String{
			return LOAD_UNITS;
		}
		
		private var _smoothing:Boolean;
		private var _imageUrl:String;
		private var _urlLoader:URLLoader;
		private var _protoLoader:ILoaderAsset;
		private var _loadStarted:Boolean;
		private var _loaded:Boolean;
		private var _displayMeasurements:Rectangle = new Rectangle(0,0,1,1);
		private var _displaysTaken:int = 0;
		
		public function ImageSource(url:String=null){
			super();
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(Event.COMPLETE, onLoadComplete);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			this.imageUrl = url;
		}
		protected function onLoadComplete(e:Event):void{
			_loaded = true;
			for(var i:* in _allMediaDisplays){
				var view:MediaView = (i as MediaView);
				var loader:ILoaderAsset = (view.asset as ILoaderAsset);
				loader.loadBytes(_urlLoader.data);
			}
			setLoadProps(int(UnitConversion.convert(_urlLoader.bytesLoaded,UnitConversion.MEMORY_BYTES,UnitConversion.MEMORY_KILOBYTES)+0.5),
						int(UnitConversion.convert(_urlLoader.bytesTotal,UnitConversion.MEMORY_BYTES,UnitConversion.MEMORY_KILOBYTES)+0.5));
		}
		protected function onLoadProgress(e:Event):void{
			setLoadProps(_urlLoader.bytesLoaded,_urlLoader.bytesTotal);
		}
		override public function takeMediaDisplay():ILayoutView{
			_displaysTaken++;
			if(!_loadStarted && _imageUrl){
				_loadStarted = true;
				_urlLoader.load(new URLRequest(imageUrl));
			}
			return super.takeMediaDisplay();
		}
		override public function returnMediaDisplay(value:ILayoutView):void{
			_displaysTaken--;
			super.returnMediaDisplay(value);
		}
		override protected function createMediaDisplay():ILayoutView{
			var loader:Loader = new Loader();
			if(_loaded){
				loader.loadBytes(_urlLoader.data);
			}
			if(!_protoLoader){
				_protoLoader = NativeAssetFactory.getNew(loader);
				_protoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onProtoLoaded);
			}
			var loaderAsset:ILoaderAsset = NativeAssetFactory.getNew(loader);
			var view:ImageView = new ImageView(loaderAsset,_displayMeasurements,smoothing);
			view.layoutInfo = new FrameLayoutInfo();
			return view;
		}
		protected function onProtoLoaded(e:Event):void{
			updateDisplayMeasurements(0,0,_protoLoader.content.width,_protoLoader.content.height);
		}
		override protected function destroyMediaDisplay(value:ILayoutView):void{
			var loader:ILoaderAsset = value.asset as ILoaderAsset;
			if(_protoLoader==loader){
				_protoLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onProtoLoaded);
				_protoLoader = null;
			}
			loader.unload();
		}
		protected function updateDisplayMeasurements(x:Number, y:Number, width:Number, height:Number):void{
			_displayMeasurements.x = x;
			_displayMeasurements.y = y;
			_displayMeasurements.width = width;
			_displayMeasurements.height = height;
			for(var i:* in _allMediaDisplays){
				var view:MediaView = (i as MediaView);
				view.displayMeasurementsChanged();
			}
		}
	}
}