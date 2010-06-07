package org.farmcode.sodalityLibrary.display.visualSockets.plugs
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;
	
	public interface IPlugDisplay extends ILayoutSubject
	{
		function setDataProvider(value: *, cause:IAdvice=null): void;
		
		/**
		 * handler(from:IPlugDisplay, oldDisplay:DisplayObject, newDisplay:DisplayObject)
		 */
		function get displayChanged():IUniversalAct;
		function get display():IDisplayAsset;
		
		function set displaySocket(value:IDisplaySocket):void;
		function get displaySocket():IDisplaySocket;
	}
}