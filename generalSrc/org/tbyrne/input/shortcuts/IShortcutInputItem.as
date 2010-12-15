package org.tbyrne.input.shortcuts
{
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.IScopedObject;

	public interface IShortcutInputItem extends IScopedObject
	{
		function get shortcutType():String;
		function get blockAscendantShortcuts():Boolean;
		function attemptExecute(keyEventInfo:IKeyActInfo, isDown:Boolean):Boolean;
	}
}