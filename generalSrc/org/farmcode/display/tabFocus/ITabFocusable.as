package org.farmcode.display.tabFocus
{
	import flash.events.IEventDispatcher;
	
	[Event(name="focusIn",type="flash.events.FocusEvent")]
	[Event(name="focusOut",type="flash.events.FocusEvent")]
	public interface ITabFocusable extends IEventDispatcher
	{
		function get focused():Boolean;
		function set focused(value:Boolean):void;
		function get tabIndicesRequired():uint;
		function set tabIndex(value:int):void;
		function set tabEnabled(value:Boolean):void;
	}
}