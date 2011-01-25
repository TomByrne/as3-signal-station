package org.tbyrne.data.dataTypes
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public interface ITriggerableAction
	{
		function triggerAction(scopeDisplay:IDisplayObject):void;
	}
}