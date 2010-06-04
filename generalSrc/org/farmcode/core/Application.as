package org.farmcode.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.farmcode.display.behaviour.LayoutViewBehaviour;
	
	/**
	 * Application adds the core abstract implementation of the IApplication
	 * interface.
	 */
	public class Application extends LayoutViewBehaviour implements IApplication
	{
		public function get container():DisplayObjectContainer{
			return _container;
		}
		public function set container(value:DisplayObjectContainer):void{
			if(_container!=value){
				if(asset && _container){
					_container.removeChild(asset);
				}
				_container = value;
				if(asset && _container){
					_container.addChild(asset);
				}
			}
		}
		override public function set asset(value:DisplayObject):void{
			if(super.asset != value){
				if(asset && _container){
					_container.removeChild(asset);
				}
				super.asset = value;
				if(asset && _container){
					_container.addChild(asset);
				}
			}
		}
		
		private var _container:DisplayObjectContainer;
		protected var _lastStage:Stage;
		protected var _inited:Boolean;
		
		public function Application(asset:DisplayObject=null){
			super(asset);
		}
		
		override protected function bindToAsset() : void{
			_lastStage = asset.stage;
			if(!_inited){
				_inited = true;
				init();
			}
			super.bindToAsset();
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_lastStage = null;
		}
		protected function init() : void{
			// override me
		}
	}
}