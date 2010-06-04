package au.com.thefarmdigital.structs
{
	import mx.rpc.IResponder;
	
	/**
	 * A recepient of notifications.
	 */
	public class Responder implements IResponder
	{
		private var resultCallback:Function;
		private var faultCallback:Function;
		
		/** A responder that is notified after this responder is notified */
		public var nextResponder:IResponder;
		
		/**
		 * Creates a new responder which notifies the given functions when a result
		 * is received
		 * 
		 * @param	result		A function to call when a result notification is 
		 * 						received
		 * @param	fault		A function to call when a fault notification is 
		 * 						received
		 */ 
		public function Responder(result:Function, fault:Function=null)
		{
			resultCallback = result;
			faultCallback = fault;
		}
		
		/**
		 * Handles a result notification.
		 * 
		 * @param	data	information about the result
		 */
		public function result(data:Object):void{
			if(resultCallback!=null)resultCallback(data);
			if(nextResponder)nextResponder.result(data);
		}
		
		/**
		 * Handles a fault notification.
		 * 
		 * @param	data	information about the fault
		 */
		public function fault(info:Object):void
		{
			if(faultCallback!=null)faultCallback(info);
			if(nextResponder)nextResponder.fault(info);
		}
	}
}