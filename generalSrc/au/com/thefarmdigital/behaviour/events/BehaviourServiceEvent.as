package au.com.thefarmdigital.behaviour.events
{
	import au.com.thefarmdigital.behaviour.behaviours.IBehaviour;
	
	import flash.events.Event;

	public class BehaviourServiceEvent extends Event
	{
		public static const BEHAVIOUR_EXECUTE: String = "behaviourExecute";
		public static const BEHAVIOUR_COMPLETE: String = "behaviourComplete";
		
		public var behaviours: Array;
		
		public function BehaviourServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var clone: BehaviourServiceEvent = new BehaviourServiceEvent(this.type);
			clone.behaviours = this.behaviours;
			return clone;
		}
	}
}