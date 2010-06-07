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
				removeMainDisplay();
				_container = value;
				addMainDisplay();
			}
		}
		public function get mainDisplay():DisplayObject{
			return _mainDisplay;
		}
		public function set mainDisplay(value:DisplayObject):void{
			if(_mainDisplay!=value){
				removeMainDisplay();
				_mainDisplay = value;
				addMainDisplay();
			}
		}
		
		private var _mainDisplay:DisplayObject;
		private var _container:DisplayObjectContainer;
		
		public function Application(asset:IDisplayAsset=null){
			super(asset);
		}
		public function removeMainDisplay():void{
			if(_mainDisplay && _container){
				_container.removeChild(_mainDisplay);
			}
		}
		public function addMainDisplay():void{
			if(_mainDisplay && _container){
				_container.addChild(_mainDisplay);
			}
		}
	}
}