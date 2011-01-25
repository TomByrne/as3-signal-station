package org.tbyrne.display.actInfo
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public interface IKeyActInfo
	{
		function get altKey():Boolean;
		function get ctrlKey():Boolean;
		function get shiftKey():Boolean;
		
		function get charCode():uint;
		function get keyCode():uint;
		function get keyLocation():uint;
		
		function get keyTarget():IDisplayObject;
	}
}