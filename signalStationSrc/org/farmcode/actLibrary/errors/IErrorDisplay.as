package org.farmcode.actLibrary.errors
{
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	
	public interface IErrorDisplay
	{
		function set errorDetails(value:ErrorDetails):void;
		function get display():IDisplayAsset;
	}
}