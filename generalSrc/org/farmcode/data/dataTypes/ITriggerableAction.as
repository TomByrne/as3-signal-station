package org.farmcode.data.dataTypes
{
	import flash.display.DisplayObject;
	
	import org.farmcode.display.assets.IDisplayAsset;

	public interface ITriggerableAction
	{
		function triggerAction(scopeDisplay:IDisplayAsset):void;
	}
}