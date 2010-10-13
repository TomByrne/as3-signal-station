package org.tbyrne.hoborg
{
	import flash.events.Event;

	public class PoolingEvent extends Event
	{
		public static const OBJECT_RELEASED:String = "objectReleased";
		
		[Property(toString="true",clonable="true")]
		public var object:Object;
		
		public function PoolingEvent(type:String=null, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		override public function clone():Event{
			var ret:PoolingEvent = new PoolingEvent(type);
			ret.object = object;
			return ret;
		}
	}
}