package au.com.thefarmdigital.events
{
	import au.com.thefarmdigital.structs.RemotingCall;
	
	import flash.events.Event;

	public class RemoteCallEvent extends Event
	{
		public static const SUCCESS	:String = "success";
		public static const FAIL	:String = "fail";
		public static const TIMEOUT	:String = "timeout";
		
		public function RemoteCallEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		override public function clone():Event{
			return new RemoteCallEvent(type,bubbles,cancelable);
		}
		
	}
}