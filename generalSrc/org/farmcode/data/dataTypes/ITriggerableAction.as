package org.farmcode.data.dataTypes
{
	import flash.display.DisplayObject;

	public interface ITriggerableAction
	{
		function triggerAction(scopeDisplay:DisplayObject):void;
	}
}