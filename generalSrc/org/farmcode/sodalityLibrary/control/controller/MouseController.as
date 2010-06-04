package org.farmcode.sodalityLibrary.control.controller
{
	import org.farmcode.sodalityLibrary.control.members.EventMember;
	import org.farmcode.sodalityLibrary.control.members.ProxyPropertyMember;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class MouseController
	{
		public function get mouseSubject():ProxyPropertyMember{
			return _mouseSubject;
		}
		public function get positionX():ProxyPropertyMember{
			return _positionX;
		}
		public function get positionY():ProxyPropertyMember{
			return _positionY;
		}
		public function get dragDiffX():ProxyPropertyMember{
			return _dragDiffX;
		}
		public function get dragDiffY():ProxyPropertyMember{
			return _dragDiffY;
		}
		public function get wheelDiff():ProxyPropertyMember{
			return _wheelDiff;
		}
		public function get clickEvent():EventMember{
			return _clickEvent;
		}
		public function get rollOverEvent():EventMember{
			return _rollOverEvent;
		}
		public function get rollOutEvent():EventMember{
			return _rollOutEvent;
		}
		
		
		public function get mouseWheel():Number{
			return _mouseWheel;
		}
		public function set mouseWheel(value:Number):void{
			if(value!=_mouseWheel){
				_mouseWheel = value;
			}
		}
		public function set subject(value:InteractiveObject):void{
			if(_subject != value){
				if(_subject){
					if(_subject.stage){
						onRemove();
					}
					_subject.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
				}
				_subject = value;
				_clickEvent.subject = _subject;
				_rollOverEvent.subject = _subject;
				_rollOutEvent.subject = _subject;
				_mouseDownEvent.subject = _subject;
				_mouseUpEvent.subject = _subject;
				
				if(_subject){
					if(_subject.stage){
						onAdded();
					}else{
						_subject.addEventListener(Event.ADDED_TO_STAGE, onAdded);
					}
				}
			}
		}
		public function get subject():InteractiveObject{
			return _subject;
		}
		public function get mouseSubjectDisplay():InteractiveObject{
			return _mouseSubjectDisplay;
		}

		private var _mouseSubjectDisplay:InteractiveObject;
		private var _subject:InteractiveObject;
		private var _mousePoint:Point;
		private var _dragPoint:Point;
		private var _mouseWheel:Number = 0;
		private var _dragging:Boolean = false;
		
		// controls
		private var _positionX:ProxyPropertyMember;
		private var _positionY:ProxyPropertyMember;
		private var _dragDiffX:ProxyPropertyMember;
		private var _dragDiffY:ProxyPropertyMember;
		private var _wheelDiff:ProxyPropertyMember;
		private var _mouseSubject:ProxyPropertyMember;
		
		private var _clickEvent:EventMember;
		private var _rollOverEvent:EventMember;
		private var _rollOutEvent:EventMember;
		private var _mouseDownEvent:EventMember;
		private var _mouseUpEvent:EventMember;
		
		public function MouseController(){
			_mousePoint = new Point();
			_dragPoint = new Point();
			
			_positionX = new ProxyPropertyMember(_mousePoint,"x");
			_positionY = new ProxyPropertyMember(_mousePoint,"y");
			
			_dragDiffX = new ProxyPropertyMember(_dragPoint,"x");
			_dragDiffY = new ProxyPropertyMember(_dragPoint,"y");
			
			_wheelDiff = new ProxyPropertyMember(this,"mouseWheel");
			
			_mouseSubject = new ProxyPropertyMember(this,"mouseSubjectDisplay");
			
			_clickEvent = new EventMember(null,MouseEvent.CLICK);
			_rollOverEvent = new EventMember(null,MouseEvent.ROLL_OVER);
			_rollOutEvent = new EventMember(null,MouseEvent.ROLL_OUT);
			_mouseDownEvent = new EventMember(null,MouseEvent.MOUSE_DOWN);
			_mouseUpEvent = new EventMember(null,MouseEvent.MOUSE_UP);
		}
		protected function onAdded(e:Event=null):void{
			_subject.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			_subject.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			_mousePoint.x = _subject.mouseX;
			_mousePoint.x = _subject.mouseY;
			/*_subject.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);*/
			_subject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_subject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			/*_subject.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_subject.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_subject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);*/
			_subject.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			/*_subject.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			_subject.addEventListener(MouseEvent.ROLL_OVER, onRollOver);*/
		}
		protected function onRemove(e:Event=null):void{
			_subject.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			_subject.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			/*_subject.addEventListener(MouseEvent.CLICK, onClick);
			_subject.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);*/
			_subject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_subject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			/*_subject.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_subject.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_subject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);*/
			_subject.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			/*_subject.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			_subject.addEventListener(MouseEvent.ROLL_OVER, onRollOver);*/
		}
		protected function onMouseDown(e:MouseEvent):void{
			_dragging = true;
			_dragPoint.x = 0;
			_dragPoint.y = 0;
			_subject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_subject.addEventListener(MouseEvent.ROLL_OUT, onMouseUp);
		}
		protected function onMouseUp(e:MouseEvent):void{
			_dragging = false;
			_subject.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_subject.removeEventListener(MouseEvent.MOUSE_OUT, onMouseUp);
		}
		
		protected function onMouseMove(e:MouseEvent):void{
			var newSubject:InteractiveObject = e.target as InteractiveObject;
			if(newSubject!=_mouseSubjectDisplay){
				_mouseSubjectDisplay = newSubject;
				_mouseSubject.dispatchChange();
			}
			
			if(_dragging){
				_dragPoint.x = _subject.mouseX-_mousePoint.x;
				_dragPoint.y = _subject.mouseY-_mousePoint.y;
				_dragDiffX.dispatchChange();
				_dragDiffY.dispatchChange();
				_dragPoint.x = 0;
				_dragPoint.y = 0;
			}
			_mousePoint.x = _subject.mouseX
			_mousePoint.y = _subject.mouseY
			
			_positionX.dispatchChange();
			_positionY.dispatchChange();
		}
		protected function onMouseWheel(e:MouseEvent):void{
			_mouseWheel = e.delta;
			_wheelDiff.dispatchChange();
			_mouseWheel = 0;
		}
	}
}