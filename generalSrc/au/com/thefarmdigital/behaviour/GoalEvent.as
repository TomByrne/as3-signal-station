package au.com.thefarmdigital.behaviour
{
	import flash.events.Event;

	public class GoalEvent extends Event
	{
		public static const GOAL_CHANGED:String = "goalChanged";
		public static const GOAL_COMPLETE:String = "goalComplete";
		
		public function GoalEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}