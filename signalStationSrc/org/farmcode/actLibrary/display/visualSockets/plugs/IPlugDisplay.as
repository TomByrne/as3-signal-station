package org.farmcode.actLibrary.display.visualSockets.plugs
{
	import flash.display.DisplayObject;
	
	import org.farmcode.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.farmcode.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.display.layout.ILayoutSubject;
	
	public interface IPlugDisplay extends ILayoutSubject
	{
		function setDataProvider(value: *, cause:IFillSocketAct=null): void;
		
		/**
		 * handler(from:IPlugDisplay, oldDisplay:DisplayObject, newDisplay:DisplayObject)
		 */
		function get displayChanged():IUniversalAct;
		function get display():DisplayObject;
		
		function set displaySocket(value:IDisplaySocket):void;
		function get displaySocket():IDisplaySocket;
	}
}