package org.tbyrne.data.dataTypes
{
	import flash.display.BitmapData;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;

	public interface IBitmapDataProvider
	{
		/**
		 * handler(from:IBitmapProvider)
		 */
		function get bitmapDataChanged():IAct;
		function get bitmapData():BitmapData;
	}
}