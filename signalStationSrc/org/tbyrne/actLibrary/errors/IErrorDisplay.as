package org.tbyrne.actLibrary.errors
{
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	
	public interface IErrorDisplay
	{
		function set errorDetails(value:ErrorDetails):void;
		function get display():IDisplayAsset;
	}
}