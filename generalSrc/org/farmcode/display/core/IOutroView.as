package org.farmcode.display.core
{
	public interface IOutroView
	{
		/**
		 * Called before the removal of the display, should return the amount of (in seconds)
		 * needed for the outro to complete.
		 */
		function showOutro():Number;
	}
}