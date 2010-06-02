package org.farmcode.sodality.events
{
	import flash.events.ErrorEvent;

	public class AdviceErrorEvent extends ErrorEvent
	{		
		public function AdviceErrorEvent(type: String, bubbles: Boolean = false, 
			cancelable: Boolean = false, text: String = "")
		{
			super(type, bubbles, cancelable, text);
		}	
	}
}