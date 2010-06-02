package org.farmcode.queueing.queueItems.external
{
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public class ByteLoaderQI extends AbstractLoaderQI
	{
		public var bytes:ByteArray;
		public var loaderContext:LoaderContext;
		
		public function ByteLoaderQI(loader:Loader=null, bytes:ByteArray=null, loaderContext:LoaderContext=null){
			super(loader);
			this.bytes = bytes;
			this.loaderContext = loaderContext;
		}
		override protected function executeLoad():void{
			loader.loadBytes(bytes,loaderContext);
		}
	}
}