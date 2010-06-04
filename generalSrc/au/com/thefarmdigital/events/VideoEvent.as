package au.com.thefarmdigital.events
{
	import flash.events.Event;

	public class VideoEvent extends Event
	{
		public static const LOAD_BEGIN:String = "loadBegin";
		public static const METADATA_READY:String = "metadataReady";
		public static const CUE_POINT_HIT:String = "cuePointHit";
		public static const PLAY_START:String = "playStart";
		public static const PLAY_STOP:String = "playStop";
		
		public static const BUFFERED_CHANGE:String = "bufferedChange";
		public static const PLAYING_CHANGE:String = "playingChange";
		public static const PLAYHEAD_CHANGE:String = "playheadChange";
		
		public var cuePoint:Object;
		
		public function VideoEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, cuePoint:Object=null)
		{
			super(type, bubbles, cancelable);
			this.cuePoint = cuePoint;
		}
		
	}
}