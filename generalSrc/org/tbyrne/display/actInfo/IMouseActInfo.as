package org.tbyrne.display.actInfo
{
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;

	public interface IMouseActInfo
	{
		function get mouseTarget():IDisplayAsset;
		function get altKey():Boolean;
		function get ctrlKey():Boolean;
		function get shiftKey():Boolean;
	}
}