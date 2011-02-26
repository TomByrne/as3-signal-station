package org.tbyrne.queueing.queueItems.external
{
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.tbyrne.queueing.queueItems.PendingResultQueueItem;

	public class AbstractLoaderQI extends PendingResultQueueItem
	{
		override public function get totalSteps():uint{
			return 1;
		}
		
		public var loader:Loader;
		
		public function AbstractLoaderQI(loader:Loader=null){
			super();
			this.loader = loader;
		}
		override public function step(currentStep:uint):void{
			if(loader){
				executeLoad();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFail);
			}else{
				Log.error( "AbstractLoaderQI.step: LoaderQI needs a Loader");
			}
		}
		protected function executeLoad():void{
			// override me
		}
		protected function onComplete(e:Event):void{
			var loaderInfo:LoaderInfo = (e.target as LoaderInfo);
			_result = loaderInfo.content;
			removeListeners(loaderInfo);
			dispatchSuccess()
		}
		protected function onFail(e:Event):void{
			var loaderInfo:LoaderInfo = (e.target as LoaderInfo);
			_result = null;
			removeListeners(loaderInfo);
			dispatchFail();
		}
		protected function removeListeners(contentLoaderInfo:LoaderInfo):void{
			contentLoaderInfo.removeEventListener(Event.COMPLETE,onComplete);
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onFail);
		}
	}
}