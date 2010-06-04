package org.farmcode.media.image
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	import org.farmcode.display.layout.frame.FrameLayoutInfo;
	import org.farmcode.math.UnitConversion;
	import org.farmcode.media.MediaSource;
	import org.farmcode.media.MediaViewBehaviour;
	
	public class ImageSource extends MediaSource
	{
		private static const LOAD_UNITS:String = "Kb";
		
		public function get url():String{
			return _url;
		}
		public function set url(value:String):void{
			if(_url!=value){
				if(_url && _loadStarted){
					_urlLoader.close();
					for(var i:* in _allMediaDisplays){
						var view:MediaViewBehaviour = (i as MediaViewBehaviour);
						var loader:Loader = (view.asset as Loader);
						loader.unload();
					}
				}
				_url = value;
				_loadStarted = false;
				if(_url && _displaysTaken>0){
					startLoad();
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
					var view:ImageViewBehaviour = (i as ImageViewBehaviour);
					view.smoothing = value;
				}
			}
		}
		
		override public function get loadUnits():String{
			return LOAD_UNITS;
		}
		
		private var _smoothing:Boolean;
		private var _url:String;
		private var _urlLoader:URLLoader;
		private var _protoLoader:Loader;
		private var _loadStarted:Boolean;
		private var _loaded:Boolean;
		private var _displayMeasurements:Rectangle = new Rectangle(0,0,1,1);
		private var _displaysTaken:int = 0;
		
		public function ImageSource(url:String=null){
			super();
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(Event.COMPLETE, onLoadComplete);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			this.url = url;
		}
		protected function onLoadComplete(e:Event):void{
			_loaded = true;
			for(var i:* in _allMediaDisplays){
				var view:MediaViewBehaviour = (i as MediaViewBehaviour);
				var loader:Loader = (view.asset as Loader);
				loader.loadBytes(_urlLoader.data);
			}
			setLoadProps(int(UnitConversion.convert(_urlLoader.bytesLoaded,UnitConversion.MEMORY_BYTES,UnitConversion.MEMORY_KILOBYTES)+0.5),
						int(UnitConversion.convert(_urlLoader.bytesTotal,UnitConversion.MEMORY_BYTES,UnitConversion.MEMORY_KILOBYTES)+0.5));
		}
		protected function onLoadProgress(e:Event):void{
			setLoadProps(_urlLoader.bytesLoaded,_urlLoader.bytesTotal);
		}
		protected function onLoadError(e:Event):void{
			if(_loadFailed)_loadFailed.perform(this);
		}
		override public function takeMediaDisplay():ILayoutViewBehaviour{
			_displaysTaken++;
			if(_url){
				startLoad();
			}
			return super.takeMediaDisplay();
		}
		public function startLoad():void{
			if(!_url)throw new Error("startLoad cannot be called until url is set");
			if(!_loadStarted){
				_loadStarted = true;
				_urlLoader.load(new URLRequest(_url));
			}
		}
		override public function returnMediaDisplay(value:ILayoutViewBehaviour):void{
			_displaysTaken--;
			super.returnMediaDisplay(value);
		}
		override protected function createMediaDisplay():ILayoutViewBehaviour{
			var loader:Loader = new Loader();
			if(_loaded){
				loader.loadBytes(_urlLoader.data);
			}
			if(!_protoLoader){
				_protoLoader = loader;
				_protoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onProtoLoaded);
			}
			var view:ImageViewBehaviour = new ImageViewBehaviour(loader,_displayMeasurements,smoothing);
			view.layoutInfo = new FrameLayoutInfo();
			return view;
		}
		protected function onProtoLoaded(e:Event):void{
			updateDisplayMeasurements(0,0,_protoLoader.content.width,_protoLoader.content.height);
		}
		override protected function destroyMediaDisplay(value:ILayoutViewBehaviour):void{
			var loader:Loader = value.asset as Loader;
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
				var view:MediaViewBehaviour = (i as MediaViewBehaviour);
				view.displayMeasurementsChanged();
			}
		}
	}
}