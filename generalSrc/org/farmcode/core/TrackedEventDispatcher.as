package org.farmcode.core
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	public class TrackedEventDispatcher extends EventDispatcher
	{
		private var listenerLists:Dictionary = new Dictionary();
		private var capListenerLists:Dictionary = new Dictionary();
		private var clearing:Boolean;
		
		public function TrackedEventDispatcher(target:IEventDispatcher=null){
			super(target);
		}
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false) : void{
			var _listenerLists:Dictionary = (useCapture?capListenerLists:listenerLists);
			var listeners:Dictionary = _listenerLists[type];
			if(!listeners){
				listeners = _listenerLists[type] = new Dictionary();
			}
			listeners[listener] = true;
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false) : void{
			if(!clearing){
				var _listenerLists:Dictionary = (useCapture?capListenerLists:listenerLists);
				var listeners:Dictionary = _listenerLists[type];
				if(listeners){
					delete listeners[listener];
				}
			}
			super.removeEventListener(type, listener, useCapture);
		}
		public function clearAllListeners():void{
			clearing = true;
			var lists:Array = [listenerLists,capListenerLists];
			var capture:Boolean;
			for each(var list:Dictionary in lists){
				for(var event:String in list){
					var listeners:Dictionary = list[event];
					for(var i:* in listeners){
						removeEventListener(event,i as Function, capture);
					}
					delete list[event];
				}
				capture = true;
			}
			clearing = false;
		}
	}
}