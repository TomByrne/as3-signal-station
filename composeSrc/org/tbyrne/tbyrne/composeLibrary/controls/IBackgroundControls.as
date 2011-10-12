package org.tbyrne.tbyrne.composeLibrary.controls
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IBackgroundControls
	{
		/**
		 * handler(from:IBackgroundControls)
		 */
		function get backgroundColourChanged():IAct;
		function get backgroundColour():uint;
		function set backgroundColour(value:uint):void;
		
		/**
		 * handler(from:IBackgroundControls)
		 */
		function get backgroundAlphaChanged():IAct;
		function get backgroundAlpha():Number;
		function set backgroundAlpha(value:Number):void;
	}
}