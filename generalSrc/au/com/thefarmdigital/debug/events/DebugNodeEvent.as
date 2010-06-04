package au.com.thefarmdigital.debug.events
{
	import flash.events.Event;

	public class DebugNodeEvent extends Event
	{
		public static const NODE_CHANGE:String = "nodeChange";
		
		public function DebugNodeEvent(type:String){
			super(type);
		}
	}
}