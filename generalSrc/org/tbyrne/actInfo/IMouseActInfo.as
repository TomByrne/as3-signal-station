package org.tbyrne.actInfo
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public interface IMouseActInfo
	{
		function get mouseTarget():*;
		function get altKey():Boolean;
		function get ctrlKey():Boolean;
		function get shiftKey():Boolean;
		
		function get screenX():Number;
		function get screenY():Number;
	}
}