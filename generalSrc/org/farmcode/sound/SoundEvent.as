package org.farmcode.sound
{
	import org.farmcode.sound.soundControls.ISoundControl;
	
	import flash.events.Event;

	public class SoundEvent extends Event
	{
		public static const PLAYBACK_BEGUN:String = "playbackBegun";
		public static const PLAYBACK_FINISHED:String = "playbackFinished";
		public static const SOUND_ADDED:String = "soundAdded";
		public static const SOUND_REMOVED:String = "soundRemoved";
		
		public var soundControl:ISoundControl;
		
		public function SoundEvent(soundControl:ISoundControl, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.soundControl = soundControl;
		}
		
	}
}