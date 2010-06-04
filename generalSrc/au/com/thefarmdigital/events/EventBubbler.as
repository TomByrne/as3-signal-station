package au.com.thefarmdigital.events
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	/**
	 * EventBubbler extends EventBubbling to non-display classes
	 */
	public class EventBubbler
	{
		private var parent:IEventDispatcher;
		private var children:Array = [];
		
		public function EventBubbler(parent:IEventDispatcher){
			super();
			this.parent = parent;
		}
		public function addChild(child:IEventDispatcher, events:Array):void{
			var index:Number = findChildIndex(child);
			if(index==-1){
				var dif:Array = [];
				var alreadyEvents:Array = (children[index] as EventBubblerChild).events;
				var length:int = events.length;
				for(var i:int=0; i<length; ++i){
					var event:String = events[i];
					index = alreadyEvents.indexOf(event);
					if(index==-1){
						dif.push(event);
						alreadyEvents.push(event);
					}
				}
				adjustListeners(child,dif,true);
			}else{
				children.push(new EventBubblerChild(child,events));
				adjustListeners(child,events,true);
			}
		}
		public function removeChild(child:IEventDispatcher):void{
			var index:Number = findChildIndex(child);
			if(index!=-1){
				var bundle:EventBubblerChild = children[index];
				adjustListeners(bundle.child, bundle.events, false);
				children.splice(index,1);
			}
		}
		protected function findChildIndex(child:IEventDispatcher):int{
			var length:int = children.length;
			for(var i:int=0; i<length; ++i){
				var bundle:EventBubblerChild = children[i];
				if(bundle.child==child){
					return i;
				}
			}
			return -1;
		}
		protected function adjustListeners(child:IEventDispatcher, events:Array, add:Boolean):void{
			var length:int = events.length;
			for(var i:int=0; i<length; ++i){
				if(add)child.addEventListener(events[i],bubbleEvent);
				else child.removeEventListener(events[i],bubbleEvent);
			}
		}
		protected function bubbleEvent(e:Event):void{
			if(e.bubbles)parent.dispatchEvent(e);
		}
	}
}
	import flash.events.IEventDispatcher;
	
class EventBubblerChild{
	public var child:IEventDispatcher;
	public var events:Array;
	
	public function EventBubblerChild(child:IEventDispatcher, events:Array){
		this.child = child;
		this.events = events;
	}
}