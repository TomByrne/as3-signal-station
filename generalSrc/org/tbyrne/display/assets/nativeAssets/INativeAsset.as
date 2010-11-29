package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.display.assets.assetTypes.IAsset;
	
	public interface INativeAsset extends IAsset
	{
		function get displayObject():DisplayObject;
	}
}