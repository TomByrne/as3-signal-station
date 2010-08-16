package org.farmcode.media
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.display.core.ILayoutView;

	public interface IMediaSource
	{
		function get loadProgress():INumberProvider;
		function get loadTotal():INumberProvider;
		function get loadUnits():IStringProvider;
		
		/**
		 * handler(from:IMediaSource)
		 */
		function get loadCompleted():IAct;
		
		function takeMediaDisplay():ILayoutView;
		function returnMediaDisplay(value:ILayoutView):void;
	}
}