package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	
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
		
		public function get contentLoaderInfo():LoaderInfo{
			return _loader.contentLoaderInfo;
		}
	}
}