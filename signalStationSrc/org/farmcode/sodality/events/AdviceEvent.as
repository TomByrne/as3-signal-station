package org.farmcode.sodality.events
{
	import flash.events.Event;

	public class AdviceEvent extends Event
	{
		public static const EXECUTE:String = "execute";
		public static const CONTINUE:String = "continue";
		public static const COMPLETE:String = "complete";
		
		public function AdviceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}