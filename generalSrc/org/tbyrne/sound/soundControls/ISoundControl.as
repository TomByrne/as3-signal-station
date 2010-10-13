package org.tbyrne.sound.soundControls
{
	import org.tbyrne.acting.actTypes.IAct;
	
	/**
	 * The ISoundControl interface provides control for sound playback, generally it wraps
	 * a Sound or NetStream object.
	 */
	public interface ISoundControl
	{
		
		/**
		 * handler(from:ISoundControl)
		 */
		function get playbackBegun():IAct;
		/**
		 * handler(from:ISoundControl)
		 */
		function get playbackFinished():IAct;
		/**
		 * handler(from:ISoundControl)
		 */
		function get soundAdded():IAct;
		/**
		 * handler(from:ISoundControl)
		 */
		function get soundRemoved():IAct;
		
		function play():void;
		function stop():void;
		/**
		 * This is the multiplier that the SoundManager uses to control this sound.
		 */
		function set volumeMultiplier(value:Number):void;
		function get volumeMultiplier():Number;
		function get playing():Boolean;
		function get infinite():Boolean;
		function get soundGroup():String; // currently can only change volume and queue name
		/**
		 * This is to be set by the SoundManager to trigger the soundsAdded
		 * and soundRemoved acts.
		 */
		function set added(value:Boolean):void;
	}
}