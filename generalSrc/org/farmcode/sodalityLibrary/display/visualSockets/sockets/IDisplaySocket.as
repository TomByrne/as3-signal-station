package org.farmcode.sodalityLibrary.display.visualSockets.sockets
{
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.IPlugDisplay;

	[Event(name="plugDisplayChanged",type="org.farmcode.sodalityLibrary.display.visualSockets.events.DisplaySocketEvent")]
	public interface IDisplaySocket extends IEventDispatcher
	{
		function get socketId(): String;
		function get plugMappers(): Array;
		function get globalPosition(): Rectangle;
		
		function get plugDisplay():IPlugDisplay;
		function set plugDisplay(value:IPlugDisplay):void;

		function set socketPath(value:String):void;
		function get socketPath():String;
	}
}