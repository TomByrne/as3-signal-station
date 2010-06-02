package org.farmcode
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.farmcode.acting.IScopeDisplayObject;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	
	public class ScopeDisplayObject implements IScopeDisplayObject
	{
		protected var _active:Boolean = true;
		protected var _scopeDisplay:DisplayObject;
		protected var _scopeDisplayStage:Stage;
		protected var _scopeDisplayChanged:Act = new Act();
		protected var _added:Boolean;
		
		
		/**
		 * handler(from:ScopeDisplayObject)
		 */
		public function get addedChanged():IAct{
			if(!_addedChanged)_addedChanged = new Act();
			return _addedChanged;
		}
		
		protected var _addedChanged:Act;
		
		/**
		 * @inheritDoc
		 */
		public function get scopeDisplayChanged():IAct{
			return _scopeDisplayChanged;
		}
		
		public function get added():Boolean{
			return _added;
		}
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_active != value){
				_active = value;
				checkAdded();
			}
		}
		public function get scopeDisplay():DisplayObject{
			return _scopeDisplay;
		}
		public function set scopeDisplay(value:DisplayObject):void{
			if(_scopeDisplay!=value){
				if(_scopeDisplay){
					_scopeDisplay.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
					_scopeDisplay.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
				}
				_scopeDisplay = value;
				if(_scopeDisplay){
					_scopeDisplay.addEventListener(Event.ADDED_TO_STAGE, onAdded);
					_scopeDisplay.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
					setStage(_scopeDisplay.stage);
				}else{
					setStage(null);
				}
				_scopeDisplayChanged.perform(this);
			}
		}
		protected function setStage(stage:Stage):void{
			_scopeDisplayStage = stage;
			checkAdded();
		}
		protected function onAdded(e:Event):void{
			setStage(_scopeDisplay.stage);
		}
		protected function onRemoved(e:Event):void{
			setStage(null);
		}
		protected function checkAdded():void{
			var shouldAdd:Boolean = shouldAddToManager();
			if(shouldAdd){
				if(!_added){
					_added = true;
					if(_addedChanged)_addedChanged.perform(this);
				}
			}else if(_added){
				_added = false;
				if(_addedChanged)_addedChanged.perform(this);
			}
		}
		protected function shouldAddToManager():Boolean{
			return _active && _scopeDisplay!=null && _scopeDisplayStage;
		}
	}
}