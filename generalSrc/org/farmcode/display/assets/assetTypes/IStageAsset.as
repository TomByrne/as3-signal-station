package org.farmcode.display.assets.assetTypes
{
	import flash.display.LoaderInfo;
	
	import org.farmcode.acting.actTypes.IAct;

	public interface IStageAsset extends IContainerAsset
	{
		//TODO: change handler signature
		/**
		 * handler(e:Event, from:IStageAsset)
		 */
		function get resize():IAct;
		/**
		 * handler(e:Event, from:IStageAsset)
		 */
		function get fullScreen():IAct;
		
		function get focus():IInteractiveObjectAsset;
		function set focus(value:IInteractiveObjectAsset):void;
		
		function get stageWidth():Number;
		function get stageHeight():Number;
		
		function get frameRate():Number;
		
		function set displayState(value:String):void;
		function get displayState():String;
		
		function get loaderInfo():LoaderInfo
	}
}