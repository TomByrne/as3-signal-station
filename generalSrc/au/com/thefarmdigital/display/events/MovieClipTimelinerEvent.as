package au.com.thefarmdigital.display.events
{
	import flash.events.Event;

	public class MovieClipTimelinerEvent extends Event
	{
		public static const PLAYBACK_FINISH: String = "playbackFinish";
		
		public function MovieClipTimelinerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new MovieClipTimelinerEvent(this.type, this.bubbles, this.cancelable);
		}
	}
}