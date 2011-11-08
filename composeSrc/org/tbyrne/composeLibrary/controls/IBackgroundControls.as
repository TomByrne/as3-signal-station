package org.tbyrne.composeLibrary.controls
{
	import flash.display.BitmapData;
	
	import org.tbyrne.acting.actTypes.IAct;

	public interface IBackgroundControls
	{
		/**
		 * handler(from:IBackgroundControls)
		 */
		function get backgroundColourChanged():IAct;
		function get backgroundColour():uint;
		function set backgroundColour(value:uint):void;
	}
}