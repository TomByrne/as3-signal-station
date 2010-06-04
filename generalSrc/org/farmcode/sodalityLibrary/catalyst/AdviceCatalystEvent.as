package org.farmcode.sodalityLibrary.catalyst
{
	import flash.events.Event;

	public class AdviceCatalystEvent extends Event
	{
		public static const CATALYST_MET:String = "catalystMet";
		
		public function AdviceCatalystEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}