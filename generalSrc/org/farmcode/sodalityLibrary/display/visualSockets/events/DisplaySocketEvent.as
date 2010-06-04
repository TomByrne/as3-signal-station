package org.farmcode.sodalityLibrary.display.visualSockets.events
{
	import flash.events.Event;
	
	public class DisplaySocketEvent extends Event
	{
		public static const PLUG_DISPLAY_CHANGED:String = "plugDisplayChanged";
		
		public function DisplaySocketEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}