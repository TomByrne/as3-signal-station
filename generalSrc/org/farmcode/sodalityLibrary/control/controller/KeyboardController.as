package org.farmcode.sodalityLibrary.control.controller
{
	import org.farmcode.sodalityLibrary.control.members.EventMember;
	import org.farmcode.sodalityLibrary.control.members.ProxyPropertyMember;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	public class KeyboardController
	{
		public function set subject(value:InteractiveObject):void{
			if(_subject != value){
				if(_subject){
					_subject.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					_subject.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					_subject.stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
				}
				_subject = value;
				if(_subject){
					_subject.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					_subject.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					_subject.stage.addEventListener(Event.DEACTIVATE, onDeactivate);
				}
			}
		}
		public function get subject():InteractiveObject{
			return _subject;
		}
		private var _subject:InteractiveObject;
		
		private var downMemberCache:Dictionary = new Dictionary();
		private var upMemberCache:Dictionary = new Dictionary();
		private var holdMemberCache:Dictionary = new Dictionary();
		private var isDownMemberCache:Dictionary = new Dictionary();
		
		private var held:Array;
		private var frameListening:Boolean = false;
		
		public function KeyboardController(subject:InteractiveObject=null){
			this.held = new Array();
			this.subject = subject;
		}
		protected function onKeyDown(e:KeyboardEvent=null):void{
			var keyCode:Number = e.keyCode;
			var index:Number = held.indexOf(keyCode);
			if(index==-1){
				held.push(keyCode);
				var eventMember:EventMember = downMemberCache[keyCode];
				if(eventMember)eventMember.dispatchChange(e);
				
				var isDownMember:ProxyPropertyMember = isDownMemberCache[keyCode];
				if(isDownMember)isDownMember.value = true;
			}
			if(!frameListening){
				frameListening = true;
				_subject.addEventListener(Event.ENTER_FRAME, onHoldFrame);
			}
		}
		protected function onHoldFrame(e:Event=null):void{
			for each(var keyCode:Number in held){
				var eventMember:EventMember = holdMemberCache[keyCode];
				if(eventMember)eventMember.dispatchChange(e);
			}
		}
		protected function onKeyUp(e:KeyboardEvent):void{
			var keyCode:Number = e.keyCode;
			this.processKeyUp(keyCode);
		}
		
		protected function processKeyUp(keyCode: Number): void
		{
			var index:Number = held.indexOf(keyCode);
			if(index!=-1){
				held.splice(index,1);
				var eventMember:EventMember = upMemberCache[keyCode];
				if (eventMember)
				{
					var cEvent: KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_UP);
					cEvent.keyCode = keyCode;
					eventMember.dispatchChange(cEvent);
				}
				
				var isDownMember:ProxyPropertyMember = isDownMemberCache[keyCode];
				if(isDownMember)isDownMember.value = false;
			}
			if(frameListening && !held.length){
				frameListening = false;
				_subject.removeEventListener(Event.ENTER_FRAME, onHoldFrame);
			}
		}
		
		protected function onDeactivate(event: Event): void
		{
			while (held.length > 0)
			{
				var keyCode: Number = Number(held[0]);
				this.processKeyUp(keyCode);
			}
		}
		
		public function getDownEventMember(keyCode:Number):EventMember{
			return getEventMember(keyCode,downMemberCache);
		}
		public function getUpEventMember(keyCode:Number):EventMember{
			return getEventMember(keyCode,upMemberCache);
		}
		public function getHoldEventMember(keyCode:Number):EventMember{
			return getEventMember(keyCode,holdMemberCache);
		}
		public function getIsDownMember(keyCode:Number):ProxyPropertyMember{
			var property:ProxyPropertyMember = isDownMemberCache[keyCode];
			if(!property){
				property = new ProxyPropertyMember({},"down");
				property.value = held.indexOf(keyCode)!=-1;
				property.autoChangeDispatch = true;
				isDownMemberCache[keyCode] = property;
			}
			return property;
		}
		protected function getEventMember(keyCode:Number, dictionary:Dictionary):EventMember{
			var property:EventMember = dictionary[keyCode];
			if(!property){
				property = new EventMember();
				dictionary[keyCode] = property;
			}
			return property
		}
	}
}