package au.com.thefarmdigital.memory
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.farmcode.core.DelayedCall;
	
	public class ObjectDisposeTracker extends EventDispatcher
	{
		private var listeners: Array;
		private var delayedCalls: Array;
		private var timeouts: Array;
		private var intervals: Array;
		
		public function ObjectDisposeTracker()
		{
			this.listeners = new Array();
			this.delayedCalls = new Array();
			this.timeouts = new Array();
			this.intervals = new Array();
		}
		
		public function setTrackedTimeout(closure: Function, delay: Number, ...args): uint
		{
			var funcArgs: Array = [closure, delay];
			funcArgs = funcArgs.concat(args);
			var id: uint = flash.utils.setTimeout.apply(null, funcArgs);
			this.timeouts.push(id);
			return id;
		}
		
		public function clearTrackedTimeout(id: uint): void
		{
			var timeoutIndex: int = this.timeouts.indexOf(id);
			if (timeoutIndex > 0)
			{
				this.timeouts.splice(timeoutIndex);
			}
			clearTimeout(id);
		}
		
		public function setTrackedInterval(closure: Function, delay: Number, ...args): uint
		{
			var funcArgs: Array = [closure, delay];
			funcArgs = funcArgs.concat(args);
			var id: uint = flash.utils.setInterval.apply(null, funcArgs);
			this.intervals.push(id);
			return id;
		}
		
		public function clearTrackedInterval(id: uint): void
		{
			var index: int = this.intervals.indexOf(id);
			if (index > 0)
			{
				this.intervals.splice(index);
			}
			clearInterval(id);
		}
		
		public function registerDelayedCall(call: DelayedCall, begin: Boolean = true): void
		{
			if (this.delayedCalls.indexOf(call) < 0)
			{
				this.delayedCalls.push(call);
			}
			if (begin)
			{
				call.begin();
			}
		}
		
		private function getListener(dispatcher: IEventDispatcher, type: String, 
			listener: Function, useCapture: Boolean = false): EventListener
		{
			var target: EventListener = null;
			for (var i: uint = 0; i < this.listeners.length && target == null; ++i)
			{
				var list: EventListener = this.listeners[i];
				if (list.type == type && list.dispatcher == dispatcher && list.listener == listener)
				{
					target = list;
				}
			}
			return target;
		}
		
		public function addTrackEventListener(dispatcher: IEventDispatcher, type: String, 
			listener: Function, useCapture: Boolean = false, priority: int = 0, 
			useWeakReference: Boolean = false): void
		{
			if (dispatcher == null)
			{
				throw new ArgumentError("Cannot register null dispatcher");
			}
			
			var currentList: EventListener = this.getListener(dispatcher, type, listener);
			if (currentList == null)
			{
				this.listeners.push(new EventListener(dispatcher, type, listener, useCapture, priority, 
					useWeakReference, true));
			}
			else
			{
				currentList.add();
			}
		}
		
		public function removeTrackEventListener(dispatcher: IEventDispatcher, type: String, 
			listener: Function, useCapture: Boolean = false): void
		{
			var currentList: EventListener = this.getListener(dispatcher, type, listener, useCapture);
			if (currentList == null)
			{
				dispatcher.removeEventListener(type, listener, useCapture);
			}
			else
			{
				currentList.remove();
				this.listeners.splice(this.listeners.indexOf(currentList), 1);
			}
		}
		
		public function dispose(): void
		{
			while (this.listeners.length > 0)
			{
				var list: EventListener = this.listeners.pop() as EventListener;
				list.remove();
			}
			
			while (this.delayedCalls.length > 0)
			{
				var call: DelayedCall = this.delayedCalls.pop() as DelayedCall;
				call.clear();
			}
			
			while (this.timeouts.length > 0)
			{
				this.clearTrackedTimeout(this.timeouts.pop() as uint);
			}
			
			while (this.intervals.length > 0)
			{
				this.clearTrackedInterval(this.intervals.pop() as uint);
			}
		}
	}
}

import flash.events.IEventDispatcher;

class EventListener
{
	public var listener: Function;
	public var type: String;
	public var dispatcher: IEventDispatcher;
	public var useCapture: Boolean;
	public var priority: int;
	public var useWeakReference: Boolean;
	
	public function EventListener(dispatcher: IEventDispatcher, type: String, listener: Function, 
		useCapture: Boolean, priority: int, useWeakReference: Boolean, addNow: Boolean = false)
	{
		this.dispatcher = dispatcher;
		this.type = type;
		this.listener = listener;
		this.useCapture = useCapture;
		this.priority = priority;
		this.useWeakReference = useWeakReference;
		if (addNow)
		{
			this.add();
		}
	}
	
	public function add(): void
	{
		this.dispatcher.addEventListener(this.type, this.listener, this.useCapture, this.priority, 
			this.useWeakReference);
	}
	
	public function remove(): void
	{
		this.dispatcher.removeEventListener(this.type, this.listener, this.useCapture);
	}
}