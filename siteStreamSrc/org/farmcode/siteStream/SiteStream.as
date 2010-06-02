package org.farmcode.siteStream
{
	import org.farmcode.queueing.ThreadedQueue;
	import org.farmcode.siteStream.classLoader.SWFLibraryClassLoader;
	import org.farmcode.siteStream.dataLoader.XMLFileDataLoader;
	import org.farmcode.siteStream.parsers.DefaultParser;
	
	use namespace SiteStreamNamespace;
	
	public class SiteStream extends AbstractSiteStream
	{
		public function get caseSensitive():Boolean{
			return defaultParser.caseSensitive;
		}
		public function set caseSensitive(value:Boolean):void{
			defaultParser.caseSensitive = value;
		}
		public function get baseClassURL():String{
			return classLoader.baseURL;
		}
		public function set baseClassURL(value:String):void{
			classLoader.baseURL = value;
		}
		public function get baseDataURL():String{
			return dataLoader.baseURL;
		}
		public function set baseDataURL(value:String):void{
			dataLoader.baseURL = value;
		}
		public function get rootURL():String{
			return dataLoader.rootURL;
		}
		public function set rootURL(value:String):void{
			dataLoader.rootURL = value;
			if(rootNode){
				rootNode.release();
			}
			rootNode = SiteStreamNode.getNew(siteStreamParser);
		}
		
		protected var defaultParser:DefaultParser;
		protected var classLoader:SWFLibraryClassLoader;
		protected var dataLoader:XMLFileDataLoader;
		protected var _queue:ThreadedQueue;
		
		public function SiteStream(){
			_queue = new ThreadedQueue();
			classLoader = createClassLoader();
			dataLoader = createDataLoader();
			defaultParser = createParser();
			
			dataLoader.urlAttribute = defaultParser.urlAttribute;
			
			siteStreamParser = defaultParser;
		}
		protected function createClassLoader():SWFLibraryClassLoader{
			var ret:SWFLibraryClassLoader = new SWFLibraryClassLoader();
			ret.queue = _queue;
			return ret;
		}
		protected function createDataLoader():XMLFileDataLoader{
			var ret:XMLFileDataLoader = new XMLFileDataLoader();
			ret.queue = _queue;
			return ret;
		}
		protected function createParser():DefaultParser{
			var ret:DefaultParser = new DefaultParser();
			ret.queue = _queue;
			ret.dataLoader = dataLoader;
			ret.classLoader = classLoader;
			return ret;
		}
	}
}