package au.com.thefarmdigital.behaviour
{
	import flash.events.Event;

	public class BehaviourEvent extends Event
	{
		public static const EXECUTION_COMPLETE:String = "executionComplete";
		public static const EXECUTE:String = "execute";
		
		public function BehaviourEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}