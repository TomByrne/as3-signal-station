package au.com.thefarmdigital.structs
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	/**
	 * Dispatched when the image has loaded
	 * 
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Dispatched when there are some errors in the image load
	 * 
	 * @eventType flash.events.Event.CANCEL
	 */
	[Event(name="cancel", type="flash.events.Event")]
	
	/**
	 * The ImageData class is a struct which represents an external image, it can
	 * be used to load in the external image.
	 */
	public class ImageData extends EventDispatcher
	{
		/** The width of the image if loaded, otherwise is NaN */
		public function get imageWidth():Number
		{
			var width: Number = NaN;
			if (_loader.content)
			{
				width = _loader.content.width/loader.content.scaleX;
			}
			return width;
		}
		
		/** The height of the image if loaded, otherwise is NaN */
		public function get imageHeight():Number
		{
			var height: Number = NaN;
			if (_loader.content)
			{
				height = _loader.content.height/loader.content.scaleY;
			}
			return height;
		}
		
		/** The loader used for loading in the image */
		public function get loader():Loader
		{
			return _loader;
		}
		
		/** Whether the image is loaded yet (as defined by the Event.COMPLETE event
		 	of the loader object */
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		/** Whether the image's display bitmap is smoothed for display */
		public function get smoothing(): Boolean
		{
			return this._smoothing;
		}
		/** @private */
		public function set smoothing(smoothing: Boolean): void
		{
			if(_smoothing != smoothing){
				this._smoothing = smoothing;
				if(_loader && _loader.content){
					var bitmap:Bitmap = (_loader.content as Bitmap);
					bitmap.smoothing = smoothing;
				}
			}
		}
		
		private var _smoothing: Boolean;
		private var _loader:Loader;
		private var _loaded:Boolean;
		private var _trustContent: Boolean;
		
		/** The url of the image */
		public var url:String;
		
		/**
		 * Creates a new image data representing an image.
		 * 
		 * @param	url		The url of the image
		 */
		public function ImageData(url:String = null, smoothing: Boolean = false)
		{
			this.trustContent = false;
			this.url = url;
			this.smoothing = smoothing;
			this._loaded = false;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
		}
		
		public function set trustContent(trustContent: Boolean): void
		{
			if (this._trustContent != trustContent)
			{
				this._trustContent = trustContent;
			}
		}
		public function get trustContent(): Boolean
		{
			return this._trustContent;
		}
		
		/**
		 * Loads the image data in. If the image is already loaded it will be 
		 * reloaded
		 */
		public function load():void
		{
			unload();
			if(url && url.length){
				var loaderContext:LoaderContext;
				if (this.trustContent){
					Security.allowDomain(url);
					loaderContext = new LoaderContext(true);
					loaderContext.checkPolicyFile = true;
				}
				loader.load(new URLRequest(url),loaderContext);
			}else{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * Unloads the image data
		 */
		public function unload():void
		{
			loader.unload();
			_loaded = false;
		}
		
		/**
		 * Handles the Event.COMPLETE even from the loader
		 * 
		 * @param	e		Details about the event
		 */
		protected function onLoadComplete(e:Event):void{
			_loaded = true;
			if (_loader.content is Bitmap)
			{
				var bmp: Bitmap = _loader.content as Bitmap;
				bmp.smoothing = this._smoothing;
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Handles various error events from the loader
		 * 
		 * @param	e		Details about the event
		 */
		protected function onLoadError(event: IOErrorEvent): void
		{
			trace("WARNING: ImageData error - " + event.text);
			dispatchEvent(new Event(Event.CANCEL));
		}
	}
}