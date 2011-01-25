package org.tbyrne.actLibrary.display.popup
{
	import flash.display.DisplayObjectContainer;
	
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;

	public interface IModalDisablerView 
	{
		function addDisabler(parent:IDisplayObjectContainer):void;
		function surfaceDisabler():void;
		function removeDisabler():Number;
	}
}