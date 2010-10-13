package org.tbyrne.actLibrary.display.popup
{
	import flash.display.DisplayObjectContainer;
	
	import org.tbyrne.display.assets.assetTypes.IContainerAsset;

	public interface IModalDisablerView 
	{
		function addDisabler(parent:IContainerAsset):void;
		function surfaceDisabler():void;
		function removeDisabler():Number;
	}
}