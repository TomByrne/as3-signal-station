package org.tbyrne.display.core
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;

	public interface IView
	{
		/**
		 * handler(from:IView, oldAsset:IAsset)
		 */
		function get assetChanged():IAct;
		function get asset():IDisplayAsset;
	}
}