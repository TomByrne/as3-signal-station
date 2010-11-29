package org.tbyrne.media.image
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import org.tbyrne.debug.logging.Log;
	import org.tbyrne.display.assets.assetTypes.ILoaderAsset;
	import org.tbyrne.display.assets.nativeAssets.NativeAssetFactory;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.frame.FrameLayoutInfo;
	import org.tbyrne.media.MediaSource;
	import org.tbyrne.media.MediaView;
	
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
		
		private var _smoothing:Boolean;
		private var _imageUrl:String;
		private var _urlLoader:URLLoader;
		private var _protoLoader:ILoaderAsset;
		private var _loadStarted:Boolean;
		private var _loaded:Boolean;
		private var _displaysTaken:int = 0;
		private var _nativeFactory:NativeAssetFactory;
		
		public function ImageSource(url:String=null){
			super();
			_loadUnits.stringValue = LOAD_UNITS;
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(Event.COMPLETE, onLoadComplete);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			this.imageUrl = url;
			_nativeFactory = new NativeAssetFactory();
		}
		protected function onLoadComplete(e:Event):void{
			_loaded = true;
			for(var i:* in _allMediaDisplays){
				var view:MediaView = (i as MediaView);
				var loader:ILoaderAsset = (view.asset as ILoaderAsset);
				loader.loadBytes(_urlLoader.data);
			}
			setMemoryLoadProps(_urlLoader.bytesLoaded, _urlLoader.bytesTotal);
		}
		protected function onLoadProgress(e:Event):void{
			setMemoryLoadProps(_urlLoader.bytesLoaded, _urlLoader.bytesTotal);
		}
		protected function onError(e:Event):void{
			Log.log(Log.ERROR,e);
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
				_protoLoader = _nativeFactory.getNew(loader);
				_protoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onProtoLoaded);
			}
			var loaderAsset:ILoaderAsset = _nativeFactory.getNew(loader);
			var view:ImageView = new ImageView(loaderAsset,_measurements,smoothing);
			view.layoutInfo = new FrameLayoutInfo();
			return view;
		}
		protected function onProtoLoaded(e:Event):void{
			updateDisplayMeasurements(_protoLoader.content.width,_protoLoader.content.height);
		}
		override protected function destroyMediaDisplay(value:ILayoutView):void{
			var loader:ILoaderAsset = value.asset as ILoaderAsset;
			if(_protoLoader==loader){
				_protoLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onProtoLoaded);
				_protoLoader = null;
			}
			loader.unload();
		}
	}
}