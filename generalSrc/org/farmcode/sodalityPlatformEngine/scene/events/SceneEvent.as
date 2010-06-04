package org.farmcode.sodalityPlatformEngine.scene.events
{
	import flash.events.Event;

	public class SceneEvent extends Event
	{
		public static const DISPOSE: String = "dispose";
		
		public function SceneEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}