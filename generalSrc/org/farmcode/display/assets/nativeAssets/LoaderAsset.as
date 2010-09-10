package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.ILoaderAsset;
	
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
		private var _content:IDisplayAsset;
		
		
		public function LoaderAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
		
		public function get content():IDisplayAsset{
			if(!_content && _loader.content){
				_content = _nativeFactory.getNew(_loader.content);;
			}
			return _content;
		}
		public function get contentLoaderInfo():LoaderInfo{
			return _loader.contentLoaderInfo;
		}
		public function loadBytes(bytes:ByteArray, context:LoaderContext=null):void{
			_loader.loadBytes(bytes, context);
		}
		public function unload():void{
			_loader.unload();
			_content = null;
		}
	}
}