package org.farmcode.sodalityLibrary.sound
{
	import flash.events.Event;

	public class SoundAdvisorEvent extends Event
	{
		public static const VOLUME_CHANGE: String = "volumeChange";
		
		public function SoundAdvisorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event: SoundAdvisorEvent = new SoundAdvisorEvent(this.type, this.bubbles, this.cancelable);
			return event;
		}
	}
}