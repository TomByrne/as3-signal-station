package org.tbyrne.media.video
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.dataTypes.IBooleanData;
	import org.tbyrne.data.dataTypes.INumberData;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.media.IMediaSource;
	
	/**
	 * IVideoSource is an abstract interface that enables the creation of
	 * views and monitoring of playback on any video source.
	 */
	public interface IVideoSource extends IMediaSource
	{
		
		/**
		 * handler(from:IVideoSource)
		 */
		function get playingChanged():IAct;
		function set playing(value:Boolean):void;
		function get playing():Boolean;
		
		/**
		 * handler(from:IVideoSource)
		 */
		function get bufferedChanged():IAct;
		function get buffered():Boolean;
		
		function get currentTime():INumberData;
		function get totalTime():INumberProvider;
		
		/**
		 * handler(from:IVideoSource)
		 */
		function get volumeChanged():IAct;
		function set volume(value:Number):void;
		function get volume():Number;
		
		function get muted():IBooleanData;
		
	}
}