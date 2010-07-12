package org.farmcode.actLibrary.errors
{
	import flash.events.IEventDispatcher;
	
	import org.farmcode.display.assets.IDisplayAsset;
	
	public interface IErrorDisplay extends IEventDispatcher
	{
		function set errorDetails(value:ErrorDetails):void;
		function get display():IDisplayAsset;
	}
}