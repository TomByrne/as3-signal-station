package org.farmcode.display.layout
{
	import flash.events.Event;
	
	public class LayoutEvent extends Event
	{
		//public static const MEASUREMENTS_CHANGED:String = "measurementsChanged";
		public static const CHILDREN_CHANGED:String = "childrenChanged";
		
		public function LayoutEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}