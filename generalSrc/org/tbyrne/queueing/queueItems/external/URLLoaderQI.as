package org.tbyrne.queueing.queueItems.external
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.tbyrne.queueing.queueItems.PendingResultQueueItem;

	public class URLLoaderQI extends PendingResultQueueItem
	{
		override public function get totalSteps():uint{
			return 1;
		}
		
		public var urlRequest:URLRequest;
		public var urlLoader:URLLoader;
		
		public function URLLoaderQI(urlLoader:URLLoader=null, urlRequest:URLRequest=null){
			super();
			this.urlLoader = urlLoader;
			this.urlRequest = urlRequest;
		}
		override public function step(currentStep:uint):void{
			if(urlLoader && urlRequest){
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onFail);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFail);
				urlLoader.load(urlRequest);
			}else{
				throw new Error("URLLoaderQI needs both a URLLoader and a URLRequest");
			}
		}
		protected function onComplete(e:Event):void{
			var urlLoader:URLLoader = (e.target as URLLoader);
			_result = urlLoader.data;
			removeListeners(urlLoader);
			dispatchSuccess()
		}
		protected function onFail(e:Event):void{
			var urlLoader:URLLoader = (e.target as URLLoader);
			trace("WARNING: URLLoaderQI.onFail - failed to load "+urlRequest.url);
			_result = urlLoader.data;
			removeListeners(urlLoader);
			dispatchFail();
		}
		protected function removeListeners(urlLoader:URLLoader):void{
			urlLoader.removeEventListener(Event.COMPLETE, onComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onComplete);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onComplete);
		}
	}
}