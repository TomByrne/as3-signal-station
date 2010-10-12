package org.tbyrne.application
{
	import flash.geom.Rectangle;
	
	import org.farmcode.core.IApplication;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.puremvc.as3.patterns.facade.Facade;
	
	public class PureMvcApplication implements IApplication
	{
		
		public function get container():IContainerAsset{
			return _container;
		}
		public function set container(value:IContainerAsset):void{
			if(_container!=value){
				if(_container){
					removeFromContainer();
				}
				_container = value;
				if(_container){
					addToContainer();
					if(_displayPosition)setApplicationSize();
				}
			}
		}
		
		private var _container:IContainerAsset;
		private var _displayPosition:Rectangle;
		private var _facade:Facade;
		
		
		public function PureMvcApplication(){
			init();
		}
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			if(!_displayPosition)_displayPosition = new Rectangle();
			var change:Boolean = false;
			if(_displayPosition.x!=x){
				_displayPosition.x = x;
				change = true;
			}
			if(_displayPosition.y!=y){
				_displayPosition.y = y;
				change = true;
			}
			if(_displayPosition.width!=width){
				_displayPosition.width = width;
				change = true;
			}
			if(_displayPosition.height!=height){
				_displayPosition.height = height;
				change = true;
			}
			if(change && _container){
				setApplicationSize();
			}
		}
		
		
		
		protected function init():void{
			createFacade();
			/* override me
				add initial Mediators/Proxies
			*/
		}
		protected function addToContainer():void{
			//add initial UI Mediator to container
		}
		protected function removeFromContainer():void{
			//remove initial UI Mediator to container
		}
		protected function setApplicationSize():void{
			//set initial UI Mediators size
		}
	}
}