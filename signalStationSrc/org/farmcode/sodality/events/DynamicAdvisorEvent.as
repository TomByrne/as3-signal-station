package org.farmcode.sodality.events
{
	import flash.events.Event;

	public class DynamicAdvisorEvent extends Event
	{
		public static const TRIGGERS_CHANGED:String = "triggersChanged";
		
		public function DynamicAdvisorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}