package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.ILoader;
	
	public class LoaderAsset extends DisplayObjectContainerAsset implements ILoader
	{
		public function get loader():Loader {
			return _loader;
		}
		override public function set displayObject(value:DisplayObject):void {
			super.displayObject = value;
			_loader = (value as Loader);
		}
		
		private var _loader:Loader;
		private var _content:IDisplayObject;
		
		
		public function LoaderAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
		
		public function get content():IDisplayObject{
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
		override public function set width(value:Number):void{
			super.width = value;
			if(displayObject.scaleX==0){
				displayObject.scaleX;
			}
		}
		override public function set height(value:Number):void{
			super.height = value;
			if(displayObject.scaleY==0){
				displayObject.scaleY;
			}
		}
	}
}