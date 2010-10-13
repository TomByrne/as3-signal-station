package org.tbyrne.display.tabFocus
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	
	public class InteractiveObjectFocusWrapper extends AbstractTabFocusable implements ITabFocusable{
		
		override public function get focused():Boolean{
			return _focused;
		}
		override public function set focused(value:Boolean):void{
			if(_focused!=value){
				_focused = value;
				if(_interactiveObject.stage){
					if(value)_interactiveObject.stage.focus = _interactiveObject;
					else if(_interactiveObject.stage.focus == _interactiveObject)_interactiveObject.stage.focus = null;
				}
			}
		}
		override public function set tabIndex(value:int):void{
			_interactiveObject.tabIndex = value;
		}
		override public function set tabEnabled(value:Boolean):void{
			_interactiveObject.tabEnabled = value;
		}
		override public function get tabIndicesRequired():uint{
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
			if(_focusIn)_focusIn.perform(this);
		}
		public function onFocusOut(e:FocusEvent):void{
			_focused = false;
			if(_focusOut)_focusOut.perform(this);
		}
		public function onAddedToStage(e:Event):void{
			if(_focused)_interactiveObject.stage.focus = _interactiveObject;
		}
		public function onRemovedFromStage(e:Event):void{
			if(_interactiveObject.stage.focus == _interactiveObject)_interactiveObject.stage.focus = null;
		}
	}
}