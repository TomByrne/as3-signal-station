package org.farmcode.actLibrary.errors
{
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	
	public interface IErrorDisplay extends IEventDispatcher
	{
		function set errorDetails(value:ErrorDetails):void;
		function get display():DisplayObject;
	}
}