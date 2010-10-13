package org.tbyrne.queueing.queueItems.external
{
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class LoaderQI extends AbstractLoaderQI
	{
		public var urlRequest:URLRequest;
		public var loaderContext:LoaderContext;
		
		public function LoaderQI(loader:Loader=null, urlRequest:URLRequest=null, loaderContext:LoaderContext=null){
			super(loader);
			this.urlRequest = urlRequest;
			this.loaderContext = loaderContext;
		}
		override protected function executeLoad():void{
			loader.load(urlRequest,loaderContext);
		}
	}
}