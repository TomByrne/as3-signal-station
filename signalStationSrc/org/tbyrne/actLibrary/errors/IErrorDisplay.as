package org.tbyrne.actLibrary.errors
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	public interface IErrorDisplay
	{
		function set errorDetails(value:ErrorDetails):void;
		function get display():IDisplayObject;
	}
}