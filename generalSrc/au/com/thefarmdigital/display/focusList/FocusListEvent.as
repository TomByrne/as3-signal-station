package au.com.thefarmdigital.display.focusList
{
	import flash.events.Event;

	public class FocusListEvent extends Event
	{
		public static const FOCUS_FINISHED: String = "focusFinished";
		
		public function FocusListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event: FocusListEvent = new FocusListEvent(this.type, this.bubbles, this.cancelable);
			return event;
		}
	}
}