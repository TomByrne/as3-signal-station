package org.farmcode.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.core.LayoutView;
	
	/**
	 * Application adds the core abstract implementation of the IApplication
	 * interface.
	 */
	public class Application extends LayoutView implements IApplication
	{
		public function get container():DisplayObjectContainer{
			return _container;
		}
		public function set container(value:DisplayObjectContainer):void{
			if(_container!=value){
				if(_mainDisplay && _container){
					_container.removeChild(_mainDisplay);
				}
				_container = value;
				if(_mainDisplay && _container){
					_container.addChild(_mainDisplay);
				}
			}
		}
		public function get mainDisplay():DisplayObject{
			return _mainDisplay;
		}
		public function set mainDisplay(value:DisplayObject):void{
			if(_mainDisplay!=value){
				if(_mainDisplay && _container){
					_container.removeChild(_mainDisplay);
				}
				_mainDisplay = value;
				if(_mainDisplay && _container){
					_container.addChild(_mainDisplay);
				}
			}
		}
		
		private var _mainDisplay:DisplayObject;
		private var _container:DisplayObjectContainer;
		
		public function Application(asset:IDisplayAsset=null){
			super(asset);
		}
	}
}