package org.farmcode.sodalityLibrary.control.members
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(type="flash.events.Event", name="change")]
	public class EventMember extends EventDispatcher implements ISourceMember
	{
		public function get value():*{
			return _value;
		}
		
		public function get subject():IEventDispatcher{
			return _subject;
		}
		public function set subject(value:IEventDispatcher):void{
			if(_subject!=value){
				clearListener();
				_subject = value;
				addListener();
			}
		}
		public function get event():String{
			return _event;
		}
		public function set event(value:String):void{
			if(_event!=value){
				clearListener();
				_event = value;
				addListener();
			}
		}
		public function get useCapture():Boolean{
			return _useCapture;
		}
		public function set useCapture(value:Boolean):void{
			if(_useCapture!=value){
				clearListener();
				_useCapture = value;
				addListener();
			}
		}
		
		private var _subject:IEventDispatcher;
		private var _event:String;
		private var listening:Boolean;
		private var _useCapture:Boolean;
		private var _value:Event;
		private var ignore:Boolean = false;
		
		public function EventMember(subject:IEventDispatcher=null, event:String=null, useCapture:Boolean=false){
			_subject = subject;
			_useCapture = useCapture;
			this.event = event;
		}
		public function dispatchChange(e:Event=null):void{
			if(!ignore){
				_value = e;
				ignore = true;
				dispatchEvent(new Event(Event.CHANGE));
				ignore = false;
			}
		}
		protected function clearListener():void{
			if(listening){
				_subject.removeEventListener(_event,dispatchChange);
				listening = false;
			}
		}
		protected function addListener():void{
			if(_subject && _event && !listening){
				_subject.addEventListener(_event,dispatchChange,_useCapture);
				listening = true;
			}
		}
	}
}