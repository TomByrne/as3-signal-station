package au.com.thefarmdigital.events
{
	import flash.events.Event;

	public class CalendarEvent extends Event
	{
		public static const DAY_CLICK: String = "dayClick";
		
		public var day: *;
		
		public function CalendarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}