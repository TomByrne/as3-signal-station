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
	
	import org.tbyrne.display.assets.nativeAssets.NativeAssetFactory;
	import org.tbyrne.display.assets.nativeTypes.ILoader;
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
				attemptStartLoad();
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
		
		protected var _smoothing:Boolean;
		protected var _imageUrl:String;
		protected var _urlLoader:URLLoader;
		protected var _protoLoader:ILoader;
		protected var _loadStarted:Boolean;
		protected var _loaded:Boolean;
		protected var _displaysTaken:int = 0;
		protected var _nativeFactory:NativeAssetFactory;
		
		public function ImageSource(url:String=null, smoothing:Boolean=true){
			super();
			_loadUnits.stringValue = LOAD_UNITS;
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(Event.COMPLETE, onLoadComplete);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			this.imageUrl = url;
			_nativeFactory = new NativeAssetFactory();
			this.smoothing = smoothing;
		}
		protected function onLoadComplete(e:Event):void{
			_loaded = true;
			for(var i:* in _allMediaDisplays){
				var view:MediaView = (i as MediaView);
				var loader:ILoader = (view.asset as ILoader);
				loader.loadBytes(_urlLoader.data);
			}
			setMemoryLoadProps(_urlLoader.bytesLoaded, _urlLoader.bytesTotal);
		}
		protected function onLoadProgress(e:Event):void{
			setMemoryLoadProps(_urlLoader.bytesLoaded, _urlLoader.bytesTotal);
		}
		protected function onIOError(e:Event):void{
			Log.log(Log.EXT_ERROR,"Couldn't load image: "+_imageUrl);
		}
		protected function onSecurityError(e:Event):void{
			Log.log(Log.EXT_ERROR,"There was a security error loading image: "+_imageUrl);
		}
		override public function takeMediaDisplay():ILayoutView{
			_displaysTaken++;
			attemptStartLoad();
			return super.takeMediaDisplay();
		}
		
		private function attemptStartLoad():void{
			if(!_loadStarted && _imageUrl && _displaysTaken>0){
				_loadStarted = true;
				try{
					_urlLoader.load(new URLRequest(imageUrl));
				}catch(e:SecurityError){
					Log.log(Log.EXT_ERROR,"There was a security error loading image: "+_imageUrl);
				}
			}
		}
		
		override public function returnMediaDisplay(value:ILayoutView):void{
			_displaysTaken--;
			super.returnMediaDisplay(value);
		}
		override protected function createMediaDisplay():ILayoutView{
			var loader:Loader = new Loader();
			loader.cacheAsBitmap = true;
			if(_loaded){
				loader.loadBytes(_urlLoader.data);
			}
			if(!_protoLoader){
				_protoLoader = _nativeFactory.getNew(loader);
				_protoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onProtoLoaded);
			}
			var loaderAsset:ILoader = _nativeFactory.getNew(loader);
			var view:ImageView = new ImageView(loaderAsset,_measurements,smoothing);
			view.layoutInfo = new FrameLayoutInfo();
			return view;
		}
		protected function onProtoLoaded(e:Event):void{
			updateDisplayMeasurements(_protoLoader.content.width,_protoLoader.content.height);
		}
		override protected function destroyMediaDisplay(value:ILayoutView):void{
			var loader:ILoader = value.asset as ILoader;
			if(_protoLoader==loader){
				_protoLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onProtoLoaded);
				_protoLoader = null;
			}
			loader.unload();
		}
	}
}