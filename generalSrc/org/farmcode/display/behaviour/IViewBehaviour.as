package org.farmcode.display.behaviour
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IAct;

	public interface IViewBehaviour
	{
		/**
		 * handler(from:IViewBehaviour, oldAsset:DisplayObject)
		 */
		function get assetChanged():IAct;
		function get asset():DisplayObject;
	}
}