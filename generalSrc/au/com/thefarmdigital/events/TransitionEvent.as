package au.com.thefarmdigital.events
{
	import flash.events.Event;

	public class TransitionEvent extends Event
	{
		public static const TRANSITION_BEGIN:String = "transitionBegin";
		public static const TRANSITION_CHANGE:String = "transitionChange";
		public static const TRANSITION_END:String = "transitionEnd";
		
		public function TransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		
	}
}