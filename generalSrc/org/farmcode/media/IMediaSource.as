package org.farmcode.media
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;

	public interface IMediaSource
	{
		/**
		 * handler(from:IMediaSource)
		 */
		function get loadProgressChanged():IAct;
		function get loadProgress():Number;
		
		/**
		 * handler(from:IMediaSource)
		 */
		function get loadTotalChanged():IAct;
		function get loadTotal():Number;
		
		function get loadUnits():String;
		
		/**
		 * handler(from:IMediaSource)
		 */
		function get loadCompleted():IAct;
		
		function takeMediaDisplay():ILayoutViewBehaviour;
		function returnMediaDisplay(value:ILayoutViewBehaviour):void;
	}
}