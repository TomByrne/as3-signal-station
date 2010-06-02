package org.farmcode.sodality.advisors
{
	import flash.events.IEventDispatcher;
	
	[Event(name="advisorAdded", type="org.farmcode.sodality.events.AdvisorEvent")]
	[Event(name="advisorRemoved", type="org.farmcode.sodality.events.AdvisorEvent")]
	/**
	 * The IAdvisor interface is used to tell the President which classes should
	 * be used by Sodality. If your IAdvisor class is a DisplayObject, it can be
	 * added to the President simply by adding it to the display heirarchy.<br>
	 * Once your class implements IAdvisor interface, it can use Sodality metadata to
	 * hook into Sodality.
	 */
	public interface IAdvisor extends IEventDispatcher
	{
	}
}