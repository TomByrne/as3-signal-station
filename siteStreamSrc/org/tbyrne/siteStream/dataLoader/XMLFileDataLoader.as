package org.tbyrne.siteStream.dataLoader
{
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.queueing.IQueue;
	import org.tbyrne.queueing.queueItems.external.URLLoaderQI;
	import org.tbyrne.siteStream.events.SiteStreamErrorEvent;
	
	public class XMLFileDataLoader extends EventDispatcher implements IDataLoader
	{
		public function get urlAttribute():String{
			return _urlAttribute;
		}
		public function set urlAttribute(value:String):void{
			_urlAttribute = value;
		}
		public function get rootURL():String{
			return _rootUrl;
		}
		public function set rootURL(value:String):void{
			_rootUrl = value;
		}
		public function get baseURL():String{
			return _baseUrl;
		}
		public function set baseURL(value:String):void{
			_baseUrl = value;
		}
		
		public function get queue():IQueue{
			return _queue;
		}
		public function set queue(value:IQueue):void{
			_queue = value;
		}
		
		private var _queue:IQueue;
		private var _rootUrl:String;
		private var _baseUrl:String;
		private var _urlAttribute:String = "url";
		private var pending:Dictionary = new Dictionary();
		
		public function isDataLoaded(dataInfo:IDataInfo):Boolean{
			if(dataInfo.bestData){
				var isRoot:Boolean = isRootXML(dataInfo.bestData);
				var url:String = isRoot?getRootURL():getChildURL(dataInfo.bestData);
				if(url && url.length){
					return (isRoot && dataInfo.bestData!=null);
				}else{
					return true;
				}
			}else{
				// must be empty root
				return false;
			}
		}
		public function loadData(dataInfo:IDataInfo):IPendingResult{
			var url:String = isRootXML(dataInfo.bestData)?getRootURL():getChildURL(dataInfo.bestData);
			if(url && url.length){
				var loader:URLLoader = new URLLoader();
				var ret:URLLoaderQI = new URLLoaderQI(loader,new URLRequest(url));
				ret.success.addHandler(onLoadComplete);
				ret.fail.addHandler(onLoadFail);
				_queue.addQueueItem(ret);
				pending[ret] = dataInfo;
				return ret;
			}
			throw new Error("Attempting to load load a loaded/unloadable node");
		}
		public function releaseData(dataInfo:IDataInfo):void{
			dataInfo.loadedData = null;
		} 
		
		
		// private
		protected function onLoadComplete(pend:URLLoaderQI):void{
			pend.success.removeHandler(onLoadComplete);
			pend.fail.removeHandler(onLoadFail);
			
			var dataInfo:IDataInfo = pending[pend];
			if(dataInfo){
				dataInfo.loadedData = new XML(pend.urlLoader.data);
				delete pending[pend];
			}
		}
		protected function onLoadFail(pend:URLLoaderQI):void{
			pend.success.removeHandler(onLoadComplete);
			pend.fail.removeHandler(onLoadFail);
			delete pending[pend];
			
			var errorEvent:SiteStreamErrorEvent = new SiteStreamErrorEvent(SiteStreamErrorEvent.DATA_FAILURE);
			errorEvent.text = "Failed to load file: "+pend.urlRequest.url;
			dispatchEvent(errorEvent);
		}
		protected function isRootXML(xml:XML):Boolean{
			return !xml || !xml.parent();
		}
		protected function getChildURL(xml:XML):String{
			var url:String = xml.attribute(_urlAttribute).toString();
			if(url && url.length)return(_baseUrl?_baseUrl:"")+url;
			else return null;
		}
		protected function getRootURL():String{
			var url:String = _rootUrl;
			if(url && url.length)return(_baseUrl?_baseUrl:"")+url;
			else throw new Error("No root URL found");
		}
	}
}