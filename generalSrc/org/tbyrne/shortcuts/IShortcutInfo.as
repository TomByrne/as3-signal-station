package org.tbyrne.shortcuts
{
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.IScopedObject;

	public interface IShortcutInfo extends IScopedObject
	{
		function get isActive():Boolean;
		function get shortcutType():String;
		function attemptExecute(keyEventInfo:IKeyEventInfo):Boolean;
	}
}