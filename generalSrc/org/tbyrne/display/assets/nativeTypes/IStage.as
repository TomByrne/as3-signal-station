package org.tbyrne.display.assets.nativeTypes
{
	import flash.display.*;
	
	import org.tbyrne.acting.actTypes.IAct;

	public interface IStage extends IDisplayObjectContainer
	{
		//TODO: change handler signature
		/**
		 * handler(from:IStage)
		 */
		function get resize():IAct;
		/**
		 * handler(from:IStage)
		 */
		function get fullScreen():IAct;
		
		function get focus():IInteractiveObject;
		function set focus(value:IInteractiveObject):void;
		
		function get stageWidth():Number;
		function get stageHeight():Number;
		
		function get frameRate():Number;
		
		function set displayState(value:String):void;
		function get displayState():String;
		
		function get loaderInfo():LoaderInfo;
		
		PLATFORM::air{
		
		function get nativeWindow():NativeWindow;
		
		}
	}
}