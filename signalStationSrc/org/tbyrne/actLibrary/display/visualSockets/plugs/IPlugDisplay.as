package org.tbyrne.actLibrary.display.visualSockets.plugs
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.layout.ILayoutSubject;
	
	public interface IPlugDisplay extends ILayoutSubject
	{
		function setDataProvider(value: *, execution:UniversalActExecution=null): void;
		
		/**
		 * handler(from:IPlugDisplay, oldDisplay:DisplayObject, newDisplay:DisplayObject)
		 */
		function get displayChanged():IUniversalAct;
		function get display():IDisplayObject;
		
		function set displaySocket(value:IDisplaySocket):void;
		function get displaySocket():IDisplaySocket;
	}
}