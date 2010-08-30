package org.farmcode.actLibrary.display.visualSockets.plugs
{
	import flash.display.DisplayObject;
	
	import org.farmcode.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.layout.ILayoutSubject;
	
	public interface IPlugDisplay extends ILayoutSubject
	{
		function setDataProvider(value: *, execution:UniversalActExecution=null): void;
		
		/**
		 * handler(from:IPlugDisplay, oldDisplay:DisplayObject, newDisplay:DisplayObject)
		 */
		function get displayChanged():IUniversalAct;
		function get display():IDisplayAsset;
		
		function set displaySocket(value:IDisplaySocket):void;
		function get displaySocket():IDisplaySocket;
	}
}