package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.IEventDispatcher;
	
	[Event(name="change",type="flash.events.Event")]
	public interface IValueModifier extends IEventDispatcher
	{
		function input(value:*, oldValue:*):*;
	}
}