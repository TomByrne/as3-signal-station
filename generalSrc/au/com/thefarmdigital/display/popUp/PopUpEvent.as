package au.com.thefarmdigital.display.popUp
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class PopUpEvent extends Event
	{
		public static const ADDED:String = "added";
		public static const REMOVED:String = "removed";
		public static const FOCUS_CHANGE:String = "focusChange";
		
		public var popUpDisplay:DisplayObject;
		
		public function PopUpEvent(type:String, popUpDisplay:DisplayObject, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.popUpDisplay = popUpDisplay;
		}
		
	}
}