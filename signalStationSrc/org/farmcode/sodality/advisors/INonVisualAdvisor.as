package org.farmcode.sodality.advisors
{
	import flash.display.DisplayObject;
	/**
	 * This event should actually be fired from the advisorDisplay and should bubble.
	 */
	[Event(type="org.farmcode.sodality.events.NonVisualAdvisorEvent",name="advisorAddRequest")]
	/**
	 * This event should actually be fired from the advisorDisplay and should bubble.
	 */
	[Event(type="org.farmcode.sodality.events.NonVisualAdvisorEvent",name="advisorRemoveRequest")]
	public interface INonVisualAdvisor extends IAdvisor
	{
		function set advisorDisplay(value:DisplayObject):void;
		function get advisorDisplay():DisplayObject;
		function set addedToPresident(value:Boolean):void;
		function get addedToPresident():Boolean;
	}
}