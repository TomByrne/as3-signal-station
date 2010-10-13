package org.tbyrne.display.scrolling
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IScrollMetrics
	{
		function get minimum():Number;
		function get maximum():Number;
		function get pageSize():Number;
		function get scrollValue():Number;
		function set scrollValue(value:Number):void;
		
		/**
		 * handler(from:IScrollMatrics)
		 */
		function get scrollMetricsChanged():IAct;
	}
}