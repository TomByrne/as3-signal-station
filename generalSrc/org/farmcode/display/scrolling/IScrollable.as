package org.farmcode.display.scrolling
{
	
	import org.farmcode.acting.actTypes.IAct;
	
	/**
	 * Implementing this interface allows a class to be scrolled by any of the scrolling
	 * mechanisms (e.g. ProximityScroller, ScrollBar, etc.)
	 */
	public interface IScrollable
	{
		function getScrollMetrics(direction:String):IScrollMetrics;
	}
}