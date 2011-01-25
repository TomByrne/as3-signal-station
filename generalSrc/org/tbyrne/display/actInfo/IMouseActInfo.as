package org.tbyrne.display.actInfo
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public interface IMouseActInfo
	{
		function get mouseTarget():IDisplayObject;
		function get altKey():Boolean;
		function get ctrlKey():Boolean;
		function get shiftKey():Boolean;
	}
}