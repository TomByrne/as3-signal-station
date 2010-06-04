package au.com.thefarmdigital.display.scrolling
{
	import au.com.thefarmdigital.structs.ScrollMetrics;
	
	import org.farmcode.acting.actTypes.IAct;
	
	/**
	 * Implementing this interface allows a class to be scrolled by any of the scrolling
	 * mechanisms (e.g. ProximityScroller, ScrollBar, etc.)
	 */
	public interface IScrollable
	{
		function addScrollWheelListener(direction:String):Boolean;
		function getScrollMetrics(direction:String):ScrollMetrics;
		function setScrollMetrics(direction:String, metrics:ScrollMetrics):void;
		function getScrollMultiplier(direction:String):Number;
		
		
		/**
		 * handler(from:IScrollable, direction:String, metrics:ScrollMetrics)
		 */
		function get scrollMetricsChanged():IAct;
		
		/**
		 * handler(from:IScrollable, delta:int)
		 */
		function get mouseWheel():IAct;
	}
}