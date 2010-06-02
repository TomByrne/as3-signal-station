package org.farmcode.siteStream.classLoader
{
	import flash.display.Loader;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import org.farmcode.core.IPendingResult;
	import org.farmcode.queueing.IQueue;
	import org.farmcode.queueing.queueItems.external.LoaderQI;
	import org.farmcode.reflection.ReflectionUtils;
	import org.farmcode.siteStream.events.SiteStreamErrorEvent;
	
	public class SWFLibraryClassLoader extends EventDispatcher implements IClassLoader
	{
		public function get libraryDelimiter():String{
			return _libraryDelimiter;
		}
		public function set libraryDelimiter(value:String):void{
			_libraryDelimiter = value;
		}
		public function get baseURL():String{
			return _baseURL;
		}
		public function set baseURL(value:String):void{
			_baseURL = value;
		}
		public function get queue():IQueue{
			return _queue;
		}
		public function set queue(value:IQueue):void{
			_queue = value;
		}
		
		private var _queue:IQueue;
		private var _libraryDelimiter:String = "::";
		private var _baseURL:String;
		private var _loadingLibraries:Dictionary = new Dictionary();
		private var _pendingClassInfos:Dictionary = new Dictionary();
		/** we store the libraries (after load) weakly so that they can fall out of memory
		 * as soon as all classInfo objects pointing to them are released. This slightly increases
		 * the lookup time to find a library, but saves mapping all classInfo objects to libraries.
		 */
		private var _loadedLibraries:Dictionary = new Dictionary(true); 
		/**
		 * Maps all requested IClassInfo objects to LoaderIds, this allows us to remove the library when
		 * all IClassInfo objects associated with it have been released.
		 */
		private var _infoMap:Dictionary = new Dictionary(true); 
		
		public function isClassLoaded(classInfo:IClassInfo):Boolean{
			return _isClassLoaded(classInfo,false)
		}
		protected function _isClassLoaded(classInfo:IClassInfo, forceError:Boolean):Boolean{
			if (classInfo.classPath == "*")
			{
				return true;
			}
			else
			{
				var library:Loader = classInfo.libraryID?findLoadedLibrary(classInfo.libraryID):null;
				try{
					var type:Class = ReflectionUtils.getClassByName(classInfo.classPath);
					classInfo.classRef = type
					if(type==null && library!=null){
						throw new ReferenceError("Cannot find class: "+classInfo.classPath+" in library: "+classInfo.libraryID);
					}
					if(type!=null){
						if(classInfo.libraryID)_infoMap[classInfo] = classInfo.libraryID;
						return true;
					}else{
						return false;
					}
				}catch(e:Error){
					if(!classInfo.libraryID || forceError || library!=null)throw new ReferenceError("Cannot find class: "+classInfo.classPath);
				}
				return false;
			}
		}
		public function loadClass(classInfo:IClassInfo):IPendingResult{
			var loading:LoaderQI = _loadingLibraries[classInfo.libraryID];
			if(!loading){
				loading = createQueueItem(classInfo);
				_queue.addQueueItem(loading);
				_loadingLibraries[classInfo.libraryID] = loading;
				loading.success.addHandler(onLoadComplete);
				loading.fail.addHandler(onLoadFail);
				_pendingClassInfos[loading] = [];
				if(classInfo.libraryID)_infoMap[classInfo] = classInfo.libraryID;
			}
			_pendingClassInfos[loading].push(classInfo);
			return loading;
		}
		public function createQueueItem(classInfo:IClassInfo):LoaderQI{
			var request:URLRequest = new URLRequest((_baseURL?_baseURL:"")+classInfo.libraryID);
			return new LoaderQI(new Loader(),request,new LoaderContext(false,ApplicationDomain.currentDomain));
		}
		public function releaseClass(classInfo:IClassInfo):void{
			classInfo.classRef = null;
			var id:String = _infoMap[classInfo];
			delete _infoMap[classInfo];
			if(id){
				// find any other items using the library
				for each(var i:String in _infoMap){
					if(i==id){
						return;
					}
				}
				
				// if none are found, attempt to release the library
				var library:Loader = findLoadedLibrary(id);
				if(library){
					library.unload();
					delete _loadedLibraries[library];
				}
			}
		}
		
		
		// private
		protected function findLoadedLibrary(libraryID:String):Loader{
			for(var lib:* in _loadedLibraries){
				if(_loadedLibraries[lib]==libraryID){
					return lib as Loader;
				}
			}
			return null;
		}
		protected function onLoadComplete(pendingLoad:LoaderQI):void{
			pendingLoad.success.removeHandler(onLoadComplete);
			pendingLoad.fail.removeHandler(onLoadFail);
			
			var pending:Array = _pendingClassInfos[pendingLoad];
			for each(var classInfo:IClassInfo in pending){
				_isClassLoaded(classInfo,true);
			}
			delete _pendingClassInfos[pendingLoad];
			
			var libraryID:String = pendingLoad.urlRequest.url;
			_loadedLibraries[pendingLoad.loader] = libraryID;
			delete _loadingLibraries[libraryID];
		}
		protected function onLoadFail(pendingLoad:LoaderQI):void{
			pendingLoad.success.removeHandler(onLoadComplete);
			pendingLoad.fail.removeHandler(onLoadFail);
			
			var libraryID:String = pendingLoad.urlRequest.url;
			delete _loadedLibraries[pendingLoad.loader];
			delete _loadingLibraries[libraryID];
			
			var errorEvent:SiteStreamErrorEvent = new SiteStreamErrorEvent(SiteStreamErrorEvent.CLASS_FAILURE);
			errorEvent.text = "Failed to load class Library: "+pendingLoad.urlRequest.url;
			dispatchEvent(errorEvent);
		}
	}
}