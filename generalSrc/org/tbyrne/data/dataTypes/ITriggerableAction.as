package org.tbyrne.data.dataTypes
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;

	public interface ITriggerableAction
	{
		function triggerAction(scopeDisplay:IDisplayAsset):void;
	}
}