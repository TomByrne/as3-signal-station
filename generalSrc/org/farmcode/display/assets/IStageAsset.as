package org.farmcode.display.assets
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IStageAsset extends IContainerAsset
	{
		/**
		 * handler(e:Event, from:IStageAsset)
		 */
		function get resize():IAct;
		
		function get focus():IInteractiveObjectAsset;
		function set focus(value:IInteractiveObjectAsset):void;
		
		function get stageWidth():Number;
		function get stageHeight():Number;
		
		function get frameRate():Number;
	}
}