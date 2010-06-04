package au.com.thefarmdigital.sound.soundControls
{
	import flash.events.IEventDispatcher;
	import flash.media.SoundTransform;
	
	[Event(name="playbackBegun",type="org.farmcode.sodalityLibrary.sound.SoundEvent")]
	[Event(name="playbackFinished",type="org.farmcode.sodalityLibrary.sound.SoundEvent")]
	[Event(name="soundAdded",type="org.farmcode.sodalityLibrary.sound.SoundEvent")]
	[Event(name="soundRemoved",type="org.farmcode.sodalityLibrary.sound.SoundEvent")]
	/**
	 * The ISoundControl interface provides control for sound playback, generally it wraps
	 * a Sound or NetStream object.
	 */
	public interface ISoundControl extends IEventDispatcher
	{
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
	}
}