package org.tbyrne.display.assets.nativeAssets
{
	public class EventBundle{
		public var eventName:String;
		public var actName:String;
		public var listening:Boolean;
		public var handler:Function;
		
		public function EventBundle(eventName:String, actName:String, handler:Function){
			this.eventName = eventName;
			this.actName = actName;
			this.handler = handler;
		}
	}
}