package au.com.thefarmdigital.display.focusList
{
	import flash.events.Event;

	public class FocusListItemEvent extends Event
	{
		public static const DISPOSED: String = "disposed";
		
		public function FocusListItemEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event: FocusListItemEvent = new FocusListItemEvent(this.type, this.bubbles, this.cancelable);
			return event;
		}
	}
}