package org.farmcode.actLibrary.display.popup
{
	import flash.display.DisplayObjectContainer;

	public interface IModalDisablerView 
	{
		function addDisabler(parent:DisplayObjectContainer):void;
		function surfaceDisabler():void;
		function removeDisabler():Number;
	}
}