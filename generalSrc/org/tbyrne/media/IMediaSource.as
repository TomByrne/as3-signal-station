package org.tbyrne.media
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.core.ILayoutView;

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