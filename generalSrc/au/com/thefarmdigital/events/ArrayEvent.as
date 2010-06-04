package au.com.thefarmdigital.events
{
	import flash.events.Event;

	public class ArrayEvent extends Event
	{
		public static const ARRAY_CHANGE:String = "arrayChange";
		
		public function ArrayEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}