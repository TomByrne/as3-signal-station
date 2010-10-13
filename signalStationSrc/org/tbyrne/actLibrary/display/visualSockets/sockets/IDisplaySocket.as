package org.tbyrne.actLibrary.display.visualSockets.sockets
{
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	import org.tbyrne.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.tbyrne.acting.actTypes.IAct;

	public interface IDisplaySocket
	{
		
		/**
		 * handler(from:IDisplaySocket)
		 */
		function get plugDisplayChanged():IAct;
		
		function get socketId(): String;
		function get plugMappers(): Array;
		function get globalPosition(): Rectangle;
		
		function get plugDisplay():IPlugDisplay;
		function set plugDisplay(value:IPlugDisplay):void;

		function set socketPath(value:String):void;
		function get socketPath():String;
	}
}