package au.com.thefarmdigital.behaviour.behaviours
{
	import flash.events.IEventDispatcher;
	
	[Event(name="executionComplete",type="org.farmcode.sodalityPlatformEngine.behaviour.BehaviourEvent")]
	public interface IBehaviour extends IEventDispatcher
	{
		/**
		 * Return true if this behaviour needs no more time.
		 */
		function execute(goals:Array):Boolean;
		function cancel():void;
		function finish():void;
		function get abortable():Boolean;
	}
}