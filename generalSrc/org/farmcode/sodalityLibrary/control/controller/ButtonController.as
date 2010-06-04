package org.farmcode.sodalityLibrary.control.controller
{
	import org.farmcode.sodalityLibrary.control.members.EventMember;
	
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ButtonController
	{
		public function get clickEvent():EventMember{
			return _clickEvent;
		}
		public function get holdEvent():EventMember{
			return _holdEvent;
		}
		public function get dragEvent():EventMember{
			return _dragEvent;
		}
		public function get mouseUpEvent():EventMember{
			return _mouseUpEvent;
		}
		public function get mouseDownEvent():EventMember{
			return _mouseDownEvent;
		}
		
		private var _subject:InteractiveObject;
		private var _clickEvent:EventMember;
		private var _holdEvent:EventMember;
		private var _dragEvent:EventMember;
		private var _mouseUpEvent:EventMember;
		private var _mouseDownEvent:EventMember;
		private var _lastStage:Stage;
		
		public function ButtonController(subject:InteractiveObject){
			_subject = subject;
			_clickEvent = new EventMember(subject,MouseEvent.CLICK);
			_holdEvent = new EventMember(subject,null);
			_dragEvent = new EventMember(subject,null);
			_mouseUpEvent = new EventMember(subject,null);
			_mouseDownEvent = new EventMember(subject,MouseEvent.MOUSE_DOWN);
			
			_subject.addEventListener(MouseEvent.MOUSE_DOWN, onBeginDrag);
		}
		protected function onBeginDrag(e:MouseEvent):void{
			_holdEvent.event = Event.ENTER_FRAME;
			_dragEvent.event = Event.ENTER_FRAME;
			_subject.addEventListener(MouseEvent.ROLL_OUT, onFinishHold);
			_subject.stage.addEventListener(MouseEvent.MOUSE_UP, onFinishDrag);
			_lastStage = _subject.stage;
		}
		protected function onFinishHold(e:MouseEvent):void{
			_holdEvent.event = null;
			_subject.removeEventListener(MouseEvent.ROLL_OUT, onFinishHold);
		}
		protected function onFinishDrag(e:MouseEvent):void{
			onFinishHold(e);
			_mouseUpEvent.dispatchChange(e);
			_dragEvent.event = null;
			_lastStage.removeEventListener(MouseEvent.MOUSE_UP, onFinishDrag);
		}
	}
}