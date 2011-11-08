package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display2D.types.IDisplayContainerTrait;
	import org.tbyrne.composeLibrary.display2D.types.IDisplayObjectTrait;
	import org.tbyrne.composeLibrary.display2D.types.ILayerSortingTrait;
	import org.tbyrne.composeLibrary.display2D.types.ILayeredDisplayTrait;
	
	public class LayeredContainer extends AbstractLayeredContainer implements IDisplayContainerTrait, IDisplayObjectTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get displayObjectChanged():IAct{
			return (_displayObjectChanged || (_displayObjectChanged = new Act()));
		}
		
		protected var _displayObjectChanged:Act;
		
		public function get displayObject():DisplayObject{
			return _container;
		}
		
		public function get container():DisplayObjectContainer{
			return _container;
		}
		public function set container(value:DisplayObjectContainer):void{
			if(_container!=value){
				_container = value;
				if(_displayObjectChanged)_displayObjectChanged.perform(this);
			}
		}
		
		private var _container:DisplayObjectContainer;
		
		public function LayeredContainer(container:DisplayObjectContainer){
			super();
			this.container = container;
		}
		
		
		
		override protected function getLayerIndex(layer:ILayeredDisplayTrait):int{
			return _container.getChildIndex(layer.displayObject);
		}
		override protected function setLayerIndex(layer:ILayeredDisplayTrait, count:int):void{
			_container.setChildIndex(layer.displayObject,count);
		}
		override protected function addLayerAt(layeredDisplayTrait:ILayeredDisplayTrait, addIndex:int):void{
			_container.addChildAt(layeredDisplayTrait.displayObject, addIndex);
		}
		override protected function addDisplayTrait(displayTrait:IDisplayObjectTrait):void{
			_container.addChild(displayTrait.displayObject);
		}
		override protected function removeDisplayTrait(displayTrait:IDisplayObjectTrait, displayObject:DisplayObject):void{
			_container.removeChild(displayObject);
		}
	}
}