package org.tbyrne.siteStream.events
{
	import flash.events.ErrorEvent;
	import flash.events.Event;

	public class SiteStreamErrorEvent extends ErrorEvent
	{
		public static const CLASS_FAILURE:String = "classFailure";
		public static const DATA_FAILURE:String = "dataFailure";
		
		public function SiteStreamErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		override public function clone():Event{
			var ret:SiteStreamErrorEvent = new SiteStreamErrorEvent(type,bubbles,cancelable);
			ret.text = text;
			return ret;
		}
	}
}