package org.farmcode.display.parallax.events
{
	import flash.events.Event;

	public class ParallaxEvent extends Event
	{
		public static const POSITION_CHANGED:String = "positionChanged";
		public static const DEPTH_CHANGED:String = "depthChanged";
		public static const DISPLAY_CHANGED:String = "displayChanged";
		
		public var previousX: Number;
		public var previousY: Number;
		public var previousZ: Number;
		
		public function ParallaxEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event: ParallaxEvent = new ParallaxEvent(this.type, this.bubbles, this.cancelable);
			event.previousX = this.previousX;
			event.previousY = this.previousY;
			event.previousZ = this.previousZ;
			return event;
		}
	}
}