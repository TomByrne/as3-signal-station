package au.com.thefarmdigital.events
{
	import flash.events.Event;

	public class ControlEvent extends Event
	{
		public static const BUTTON_TOGGLE:String = "buttonToggle";
		public static const USER_BUTTON_TOGGLE:String = "userButtonToggle";
		//public static const SCROLL:String = "scroll";
		public static const VALUE_CHANGE:String = "valueChange";
		public static const DATA_CHANGE:String = "dataChange";
		public static const MEASUREMENTS_CHANGE:String = "measurementsChange";
		
		public function ControlEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		override public function clone():Event{
			var ret:ControlEvent = new ControlEvent(type,bubbles,cancelable);
			return ret;
		}
	}
}