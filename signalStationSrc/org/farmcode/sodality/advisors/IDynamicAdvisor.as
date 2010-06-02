package org.farmcode.sodality.advisors
{
	import flash.events.IEventDispatcher;
	
	[Event(name="triggersChanged",type="org.farmcode.sodality.events.DynamicAdvisorEvent")]
	public interface IDynamicAdvisor extends IEventDispatcher, IAdvisor
	{
		function get triggers():Array;
	}
}