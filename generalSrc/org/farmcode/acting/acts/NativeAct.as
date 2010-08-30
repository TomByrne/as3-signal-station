package org.farmcode.acting.acts
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class NativeAct extends Act
	{
		
		public function get eventDispatcher():IEventDispatcher{
			return _eventDispatcher;
		}
		public function set eventDispatcher(value:IEventDispatcher):void{
			if(_eventDispatcher!=value){
				if(_handlerCount)attemptRemove();
				_eventDispatcher = value;
				if(_handlerCount)attemptAdd();
			}
		}
		
		public function get eventName():String{
			return _eventName;
		}
		public function set eventName(value:String):void{
			if(_eventName!=value){
				if(_handlerCount)attemptRemove();
				_eventName = value;
				if(_handlerCount)attemptAdd();
			}
		}
		
		public function get useCapture():Boolean{
			return _useCapture;
		}
		public function set useCapture(value:Boolean):void{
			if(_useCapture!=value){
				if(_handlerCount)attemptRemove();
				_useCapture = value;
				if(_handlerCount)attemptAdd();
			}
		}
		
		public function get priority():int{
			return _priority;
		}
		public function set priority(value:int):void{
			if(_priority!=value){
				if(_handlerCount)attemptRemove();
				_priority = value;
				if(_handlerCount)attemptAdd();
			}
		}
		
		public var parameters:Array;
		public var passEvent:Boolean;
		
		private var _priority:int = 0;
		private var _useCapture:Boolean=false;
		private var _eventName:String;
		private var _eventDispatcher:IEventDispatcher;
		private var _listening:Boolean;
		
		public function NativeAct(eventDispatcher:IEventDispatcher=null, eventName:String=null, parameters:Array=null, passEvent:Boolean=true){
			super();
			this.eventDispatcher = eventDispatcher;
			this.eventName = eventName;
			this.parameters = parameters;
			this.passEvent = passEvent;
		}
		override protected function setHandlerCount(value:int):void{
			super.setHandlerCount(value);
			if(_handlerCount)attemptAdd();
			else attemptRemove();
		}
		protected function attemptAdd():void{
			if(!_listening && _eventDispatcher && _eventName){
				_listening = true;
				_eventDispatcher.addEventListener(_eventName,eventHandler,_useCapture,_priority);
			}
		}
		protected function attemptRemove():void{
			if(_listening){
				_listening = false;
				_eventDispatcher.removeEventListener(_eventName,eventHandler,_useCapture);
			}
		}
		protected function eventHandler(e:Event):void{
			if(parameters){
				var realParams:Array;
				if(passEvent)realParams = [e].concat(parameters);
				else realParams = parameters;
				perform.apply(null,realParams);
			}else{
				if(passEvent)perform(e);
				else perform();
			}
		}
	}
}