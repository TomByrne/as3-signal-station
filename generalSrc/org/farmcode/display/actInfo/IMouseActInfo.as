package org.farmcode.display.actInfo
{
	import org.farmcode.display.assets.IDisplayAsset;

	public interface IMouseActInfo
	{
		function get mouseTarget():IDisplayAsset;
		function get altKey():Boolean;
		function get ctrlKey():Boolean;
		function get shiftKey():Boolean;
	}
}