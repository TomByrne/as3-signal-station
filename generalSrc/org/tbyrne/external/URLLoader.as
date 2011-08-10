package org.tbyrne.external
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.acts.NativeAct;

	public class URLLoader
	{
		
		/**
		 * handler(from:URLLoader)
		 */
		public function get complete():IAct{
			return (_complete || (_complete = new NativeAct(_urlLoader,Event.COMPLETE,[this],false)));
		}
		
		/**
		 * handler(from:URLLoader)
		 */
		public function get open():IAct{
			return (_open || (_open = new NativeAct(_urlLoader,Event.OPEN,[this],false)));
		}
		
		PLATFORM::air{
		/**
		 * handler(from:URLLoader, httpStatus:int, responseURL:String, responseHeaders:Array)
		 */
		public function get httpResponseStatus():IAct{
			if(!_httpResponseStatus){
				_httpResponseStatus = new Act();
				_urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpStatusResponse);
			}
			return _httpResponseStatus;
		}
		}
		
		/**
		 * handler(from:URLLoader, httpStatus:int)
		 */
		public function get httpStatus():IAct{
			if(!_httpStatus){
				_httpStatus = new Act();
				_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			}
			return _httpStatus;
		}
		
		/**
		 * handler(from:URLLoader, errorID:int)
		 */
		public function get ioError():IAct{
			if(!_ioError){
				_ioError = new Act();
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
			return _ioError;
		}
		
		/**
		 * handler(from:URLLoader, bytesLoaded:Number, bytesTotal:Number)
		 */
		public function get progress():IAct{
			if(!_progress){
				_progress = new Act();
				_urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			return _progress;
		}
		
		/**
		 * handler(from:URLLoader)
		 */
		public function get securityError():IAct{
			if(!_securityError){
				_securityError = new Act();
				_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
			return _securityError;
		}
		
		protected var _securityError:Act;
		protected var _progress:Act;
		protected var _ioError:Act;
		protected var _httpStatus:Act;
		protected var _httpResponseStatus:Act;
		protected var _complete:NativeAct;
		protected var _open:NativeAct;
		
		public function get bytesLoaded():uint{
			return _urlLoader.bytesLoaded;
		}
		public function get bytesTotal():uint{
			return _urlLoader.bytesTotal;
		}
		public function get data():*{
			return _urlLoader.data;
		}
		public function get dataFormat():String{
			return _urlLoader.dataFormat;
		}
		public function set dataFormat(value:String):void{
			_urlLoader.dataFormat = value;
		}
		
		private var _urlLoader:flash.net.URLLoader;
		
		public function URLLoader()
		{
			_urlLoader = new flash.net.URLLoader();
		}
		
		public function load(request:URLRequest):void{
			_urlLoader.load(request);
		}
		
		public function close():void{
			_urlLoader.close();
		}
		
		PLATFORM::air{
		protected function onHttpStatusResponse(event:HTTPStatusEvent):void
		{
			_httpResponseStatus.perform(this,event.status,event.responseURL,event.responseHeaders);
		}
		}
		
		protected function onHttpStatus(event:HTTPStatusEvent):void
		{
			_httpResponseStatus.perform(this,event.status);
		}
		
		protected function onIOError(event:IOErrorEvent):void
		{
			_ioError.perform(this,event.errorID);
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			_progress.perform(this,event.bytesLoaded,event.bytesTotal);
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			_securityError.perform(this);
		}
		
		
	}
}