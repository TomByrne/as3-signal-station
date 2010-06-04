package org.farmcode.sodalityLibrary.control.members
{
	import flash.events.IEventDispatcher;
	
	[Event(type="flash.events.Event",name="change")]
	public interface ISourceMember extends IEventDispatcher
	{
		function get value():*;
	}
}