package org.farmcode.actLibrary.external.siteStream
{
	import flash.events.Event;

	public class SiteStreamAdviceEvent extends Event
	{
		public static const CONTENT_SET: String = "contentSet";
		
		public function SiteStreamAdviceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}