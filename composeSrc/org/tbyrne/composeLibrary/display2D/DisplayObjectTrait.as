package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.types.display2D.IDisplayConsumerTrait;
	import org.tbyrne.composeLibrary.types.display2D.IDisplayObjectTrait;
	import org.tbyrne.composeLibrary.types.display2D.IInteractiveObjectTrait;
	
	public class DisplayObjectTrait extends AbstractTrait implements IDisplayObjectTrait, IInteractiveObjectTrait, IDisplayConsumerTrait
	{
		
		public function get interactiveObject():InteractiveObject{
			return _interactiveObject;
		}
		/**
		 * @inheritDoc
		 */
		public function get interactiveObjectChanged():IAct{
			return (_interactiveObjectChanged || (_interactiveObjectChanged = new Act()));
		}
		
		public function get displayObject():DisplayObject{
			return _displayObject;
		}
		public function set displayObject(value:DisplayObject):void{
			if(_displayObject!=value){
				_displayObject = value;
				if(_displayObjectChanged)_displayObjectChanged.perform(this);
			}
			
			var interactive:InteractiveObject = (value as InteractiveObject);
			if(_interactiveObject!=interactive){
				_interactiveObject = interactive;
				if(_interactiveObjectChanged)_interactiveObjectChanged.perform(this);
			}
		}
		/**
		 * @inheritDoc
		 * handler()
		 */
		public function get displayObjectChanged():IAct{
			return (_displayObjectChanged || (_displayObjectChanged = new Act()));
		}
		
		protected var _displayObjectChanged:Act;
		protected var _displayObject:DisplayObject;
		
		protected var _interactiveObjectChanged:Act;
		protected var _interactiveObject:InteractiveObject;
		
		public function DisplayObjectTrait(){
			super();
		}
		
	}
}