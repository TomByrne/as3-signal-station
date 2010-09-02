package org.farmcode.data.dataTypes
{
	import flash.display.BitmapData;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;

	public interface IBitmapDataProvider
	{
		/**
		 * handler(from:IBitmapProvider)
		 */
		function get bitmapDataChanged():IAct;
		function get bitmapData():BitmapData;
	}
}