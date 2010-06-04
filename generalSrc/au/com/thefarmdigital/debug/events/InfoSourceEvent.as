package au.com.thefarmdigital.debug.events
{
	import flash.events.Event;

	public class InfoSourceEvent extends Event
	{
		public static const INFO_CHANGE: String = "infoChange";
		
		public function InfoSourceEvent(type: String, bubbles: Boolean = false, 
			cancelable: Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	} 
}