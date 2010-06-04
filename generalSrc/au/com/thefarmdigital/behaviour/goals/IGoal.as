package au.com.thefarmdigital.behaviour.goals
{
	import au.com.thefarmdigital.behaviour.IBehavingItem;
	
	import flash.events.IEventDispatcher;

	[Event(name="goalChanged",type="org.farmcode.sodalityPlatformEngine.behaviour.GoalEvent")]
	public interface IGoal extends IEventDispatcher
	{
		function get priority():uint;
		function get progress():Number;
		function get isComplete(): Boolean;
		function get active():Boolean;
		function get behavingItem():IBehavingItem;
		function set behavingItem(value:IBehavingItem):void;
	}
}