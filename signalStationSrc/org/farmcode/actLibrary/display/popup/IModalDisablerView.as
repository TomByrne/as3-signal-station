package org.farmcode.actLibrary.display.popup
{
	import flash.display.DisplayObjectContainer;
	
	import org.farmcode.display.assets.assetTypes.IContainerAsset;

	public interface IModalDisablerView 
	{
		function addDisabler(parent:IContainerAsset):void;
		function surfaceDisabler():void;
		function removeDisabler():Number;
	}
}