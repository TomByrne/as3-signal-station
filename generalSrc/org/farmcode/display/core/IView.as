package org.farmcode.display.core
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;

	public interface IView
	{
		/**
		 * handler(from:IView, oldAsset:IAsset)
		 */
		function get assetChanged():IAct;
		function get asset():IDisplayAsset;
	}
}