package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.ILoaderAsset;
	
	public class LoaderAsset extends DisplayObjectContainerAsset implements ILoaderAsset
	{
		public function get loader():Loader {
			return _loader;
		}
		override public function set displayObject(value:DisplayObject):void {
			super.displayObject = value;
			_loader = (value as Loader);
		}
		
		private var _loader:Loader;
		
		
		public function LoaderAsset(){
			super();
		}
		
		public function get content():IDisplayAsset{
			return NativeAssetFactory.getNew(_loader.content);
		}
		public function get contentLoaderInfo():LoaderInfo{
			return _loader.contentLoaderInfo;
		}
		public function loadBytes(bytes:ByteArray, context:LoaderContext=null):void{
			_loader.loadBytes(bytes, context);
		}
		public function unload():void{
			_loader.unload();
		}
	}
}