package org.tbyrne.display.tabFocus
{
	import flash.events.IEventDispatcher;
	
	import org.tbyrne.acting.actTypes.IAct;
	
	public interface ITabFocusable
	{
		function get focused():Boolean;
		function set focused(value:Boolean):void;
		function get tabIndicesRequired():uint;
		function set tabIndex(value:int):void;
		function set tabEnabled(value:Boolean):void;
		
		/**
		 * handler(from:ITabFocusable)
		 */
		function get focusIn():IAct;
		/**
		 * handler(from:ITabFocusable)
		 */
		function get focusOut():IAct;
	}
}