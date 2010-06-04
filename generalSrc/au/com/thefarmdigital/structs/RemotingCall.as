package au.com.thefarmdigital.structs
{
	import au.com.thefarmdigital.events.RemoteCallEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Timer;
	
	import org.farmcode.math.UnitConversion;
	
	/**
	 * Dispatched when the remoting call has returned successfully
	 * 
	 * @eventType au.com.thefarmdigital.events.RemoteCallEvent.SUCCESS
	 */
	[Event(name="success", type="au.com.thefarmdigital.events.RemoteCallEvent")]
	
	/**
	 * Dispatched when the remoting call has returned unsuccessfully
	 * 
	 * @eventType au.com.thefarmdigital.events.RemoteCallEvent.FAIL
	 */
	[Event(name="fail", type="au.com.thefarmdigital.events.RemoteCallEvent")]
	
	/**
	 * Dispatched when the remoting call hasn't returned within the timeout time
	 * 
	 * @eventType au.com.thefarmdigital.events.RemoteCallEvent.TIMEOUT
	 */
	[Event(name="timeout", type="au.com.thefarmdigital.events.RemoteCallEvent")]
	
	/**
	 * A remote method that can be called and receive responses from a remote
	 * server
	 */
	public class RemotingCall extends EventDispatcher
	{
		/** The header name for sending credentials with call */
		private static const CREDENTIALS_HEADER_PARAM: String = "Credentials";
		
		/** The amount of time in seconds before the call is considered to have 
		 	timed out */
		public function get timeout():Number{
			return _timeout;
		}
		/** @private */
		public function set timeout(value:Number):void
		{
			if(value!=_timeout){
				_timeout = value;
				timer.delay = UnitConversion.convert(_timeout,UnitConversion.TIME_SECONDS,UnitConversion.TIME_MILLISECONDS);
			}
		}
		
		/** The name of the remote method */
		public var method:String;
		
		/** The parameters to pass to the remote method */
		public var parameters:Array;
		
		/** The result of calling the remote method */
		public var result:*;
		
		/** Whether to use credentials for the remote call */
		public var useCredentials: Boolean =  false;
		
		/** The user id to pass as credentials with the call */
		public var userId: String;
		
		/** The password to pass as credentials with the call */
		public var password: String;
		
		/** @private */
		protected var _timeout:Number = 60;
		
		/** @private */
		protected var timer:Timer;
		
		/** The connection used to make the method call through */
		public var netConnection:NetConnection;
		
		/**
		 * Creates a new remoting call
		 * 
		 * @param	method			The remote method this call represents
		 * @param	parameters		Paramters for the remote method
		 * @param	useCredentials	Whether this call will send credentials
		 * @param	userId			The user id to send as credentials
		 * @param	password		The password to send as credentials
		 */
		public function RemotingCall(method:String=null, parameters:Array=null, 
			useCredentials: Boolean = false, userId: String = null, 
			password: String = null){
			
			this.method = method;
			this.parameters = parameters?parameters:[];
			
			this.useCredentials = useCredentials;
			this.userId = userId;
			this.password = password;
			
			timer = new Timer(timeout*1000,1);
			timer.addEventListener(TimerEvent.TIMER, onTimeout);
		}
		
		/**
		 * Perform the remoting call by dispatching the request. Once the response
		 * comes back, one of the following events is fired:
		 * <ul>
		 * 	<li><code>RemoteCallEvent.SUCCESS</code></li>
		 * 	<li><code>RemoteCallEvent.FAIL</code></li>
		 * 	<li><code>RemoteCallEvent.TIMEOUT</code></li>
		 * </ul>
		 */
		public function call():void
		{
			var r: flash.net.Responder = new flash.net.Responder(onResult, onFail);
			
			var parameters:Array = [method, r].concat(parameters);
			
			if (useCredentials)
			{
				// Force credentials, note that this will override any previous credentials
				// registered with this connection
				var creds: Object = {userid:userId,password:password};
				netConnection.addHeader(CREDENTIALS_HEADER_PARAM, false, creds);				
			}
			
			netConnection.call.apply(null,parameters);
			timer.start();
		}
		
		/**
		 * Handles a successful result from the remoting call
		 * 
		 * @param	result		Details of the successful result
		 */
		public function onResult(result:Object):void
		{
			timer.stop();
			this.result = result;
			dispatchEvent(new RemoteCallEvent(RemoteCallEvent.SUCCESS));
		}
		
		/**
		 * Handles a failed result from the remoting call
		 * 
		 * @param	result		Details of the failed result
		 */
		public function onFail( fault:Object ):void
		{
			timer.stop();
			this.result = fault;
			dispatchEvent(new RemoteCallEvent(RemoteCallEvent.FAIL));
		}
		
		/**
		 * Handles a timeout result from the remoting call
		 * 
		 * @param	result		Details of the timeout result
		 */
		protected function onTimeout(e:TimerEvent):void
		{
			timer.stop();
			dispatchEvent(new RemoteCallEvent(RemoteCallEvent.TIMEOUT));
		}
	}
}