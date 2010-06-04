package org.farmcode.display.tabFocus
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	
	public class InteractiveObjectFocusWrapper extends EventDispatcher implements ITabFocusable{
		
		public function get focused():Boolean{
			return _focused;
		}
		public function set focused(value:Boolean):void{
			if(_focused!=value){
				_focused = value;
				if(_interactiveObject.stage){
					if(value)_interactiveObject.stage.focus = _interactiveObject;
					else if(_interactiveObject.stage.focus == _interactiveObject)_interactiveObject.stage.focus = null;
				}
			}
		}
		public function set tabIndex(value:int):void{
			_interactiveObject.tabIndex = value;
		}
		public function set tabEnabled(value:Boolean):void{
			_interactiveObject.tabEnabled = value;
		}
		public function get tabIndicesRequired():uint{
			return 1;
		}
		
		private var _interactiveObject:InteractiveObject;
		private var _focused:Boolean;
		
		public function InteractiveObjectFocusWrapper(interactiveObject:InteractiveObject){
			_interactiveObject = interactiveObject;
			_interactiveObject.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_interactiveObject.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_interactiveObject.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_interactiveObject.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		public function onFocusIn(e:FocusEvent):void{
			_focused = true;
			dispatchEvent(e);
		}
		public function onFocusOut(e:FocusEvent):void{
			_focused = false;
			dispatchEvent(e);
		}
		public function onAddedToStage(e:Event):void{
			if(_focused)_interactiveObject.stage.focus = _interactiveObject;
		}
		public function onRemovedFromStage(e:Event):void{
			if(_interactiveObject.stage.focus == _interactiveObject)_interactiveObject.stage.focus = null;
		}
	}
}