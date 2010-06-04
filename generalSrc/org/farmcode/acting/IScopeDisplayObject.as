package org.farmcode.acting
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IAct;

	public interface IScopeDisplayObject
	{
		/**
		 * handler(act:IActReaction)
		 */
		function get scopeDisplayChanged():IAct;
		function get scopeDisplay():DisplayObject;
		function set scopeDisplay(value:DisplayObject):void;
	}
}