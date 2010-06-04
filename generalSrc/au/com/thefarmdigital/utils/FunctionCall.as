package au.com.thefarmdigital.utils
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class FunctionCall
	{
		[Property(toString="true",clonable="true")]
		public var func: Function;
		[Property(toString="true",clonable="true")]
		public var parameters: Array;
		
		public function FunctionCall(func: Function = null, parameters: Array = null)
		{
			this.func = func;
			this.parameters = parameters;
		}
		
		public function perform(...rest): *
		{
			return this.func.apply(null, parameters);
		}
		public function performEvent(e:Event): void
		{
			(e.target as IEventDispatcher).removeEventListener(e.type,performEvent);
			this.func.apply(null, parameters);
		}
		
		public static function create(func: Function, parameters: Array = null, eventHandle:Boolean = false): Function
		{
			var call: FunctionCall = new FunctionCall(func, parameters);
			return eventHandle?call.performEvent:call.perform;
		}
	}
}