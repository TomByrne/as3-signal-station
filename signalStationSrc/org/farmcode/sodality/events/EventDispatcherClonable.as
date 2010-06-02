package org.farmcode.sodality.events
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import org.farmcode.collections.DictionaryUtils;
	//import org.farmcode.hoborg.ObjectPool;

	public class EventDispatcherClonable extends EventDispatcher
	{
		/*Config::DEBUG{
			private static var gettingNew:Boolean;
		}
		private static const pool:ObjectPool = new ObjectPool(EventDispatcherClonable);
		public static function getNew(target:IEventDispatcher=null):EventDispatcherClonable{
			Config::DEBUG{
				gettingNew = true;
			}
			var ret:EventDispatcherClonable = pool.takeObject();
			Config::DEBUG{
				gettingNew = false;
			}
			ret.target = target;
			return ret;
		}*/
		
		public var listeners:Dictionary = new Dictionary();
		private var _target: IEventDispatcher;
		
		public function EventDispatcherClonable(target:IEventDispatcher=null){
			super(target);
			/*Config::DEBUG{
				if(!gettingNew && this["constructor"]==EventDispatcherClonable)throw new Error("WARNING: EventDispatcherClonable should be created via EventDispatcherClonable.getNew()");
			}*/
			this._target = target;
		}
		public function clone(newTarget:IEventDispatcher=null):EventDispatcherClonable{
			var ret:EventDispatcherClonable = new EventDispatcherClonable(newTarget?newTarget:this._target);
			for each(var events:Dictionary in listeners){
				for each(var listener:Array in events){
					ret.addEventListener.apply(null,listener);
				}
			}
			return ret;
		}
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			var events:Dictionary = listeners[listener];
			if(!events){
				events = listeners[listener] = new Dictionary();
			}
			events[type] = arguments;
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			var events:Dictionary = this.listeners[listener];
			if (events)
			{
				delete events[type];
				if (!DictionaryUtils.hasItem(events))
				{
					delete this.listeners[listener];
				}
				
			}
			super.removeEventListener(type, listener, useCapture);
		}
	}
}