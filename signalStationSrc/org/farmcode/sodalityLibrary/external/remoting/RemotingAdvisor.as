package org.farmcode.sodalityLibrary.external.remoting
{
	import flash.display.DisplayObject;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.farmcode.external.RemotingNetConnection;
	import org.farmcode.math.UnitConversion;
	import org.farmcode.sodality.TriggerTiming;
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.triggers.AdviceInstanceTrigger;
	import org.farmcode.sodality.triggers.IAdviceTrigger;
	import org.farmcode.sodalityLibrary.external.remoting.adviceTypes.IRemotingAdvice;
	import org.farmcode.sodalityLibrary.external.remoting.adviceTypes.ISetRemotingCredentials;

	/**
	 * The RemotingAdvisor can globally set a gateway url/NetConnection, timeout and user details for 
	 * RemotingAdvice objects.
	 */
	public class RemotingAdvisor extends DynamicAdvisor
	{
		
		public function get url():String{
			return _url;
		}
		public function set url(value:String):void{
			if(_url != value){
				if (service != null)
				{
					if (service.connected)
					{
						service.close();
					}
					service = null;
				}
				_url = value;
				service=new RemotingNetConnection(_url);
				service.objectEncoding = ObjectEncoding.AMF3;
				
				var oldPending:Array = pendingAdvice;
				pendingAdvice = [];
				for each(var bundle:PendingExecution in oldPending){
					executeAdvice(bundle.cause, bundle.advice);
				}
			}
		}
		
		public var userId:String;
		public var password:String;
		public var timeout:Number;
		
		private var service:RemotingNetConnection;
		private var _url:String;
		
		private var pendingAdvice:Array = []; // waiting for a service to begin
		private var pendingResults:Array = []; // waiting for a response to continue
		private var pendingTriggers:Dictionary = new Dictionary();
		
		public function RemotingAdvisor(advisorDisplay:DisplayObject=null):void{
			super(advisorDisplay);
		}
		
		[Trigger(triggerTiming="before")]
		public function onCredentialsChange(cause:ISetRemotingCredentials):void{
			if(cause.userId)userId = cause.userId;
			if(cause.password)password = cause.password;
		}
		[Trigger(triggerTiming="before")]
		public function onBeforeRemoting(cause:IRemotingAdvice, advice:AsyncMethodAdvice, timing:String):void{
			cause.addEventListener(AdviceEvent.EXECUTE, onRemotingExecute);
			advice.adviceContinue();
		}
		protected function onRemotingExecute(e:AdviceEvent):void{
			var cast:IRemotingAdvice = e.target as IRemotingAdvice;
			cast.removeEventListener(AdviceEvent.EXECUTE, onRemotingExecute);
			var trigger:IAdviceTrigger = new AdviceInstanceTrigger(cast,[new AsyncMethodAdvice(this,"onAfterRemoting")],TriggerTiming.BEFORE);
			pendingTriggers[cast] = trigger;
			addTrigger(trigger);
		}
		public function onAfterRemoting(cause:IRemotingAdvice, advice:AsyncMethodAdvice, timing:String):void{
			var trigger:IAdviceTrigger = pendingTriggers[cause];
			removeTrigger(trigger);
			if(service){
				executeAdvice(cause, advice);
			}else{
				pendingAdvice.push(new PendingExecution(cause,advice));
			}
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
		protected function executeAdvice(cause:IRemotingAdvice, advice:AsyncMethodAdvice):void{
			cause.resultType = RemotingAdviceResultType.PENDING;
			cause.result = null;
			
			
			var netConn:RemotingNetConnection = (cause.netConnection || service);
			if(netConn){
				var timer:Timer;
				var timeout:Number = (cause.timeout || this.timeout);
				if(!isNaN(timeout) && timeout){
					timer = new Timer(UnitConversion.convert(timeout,UnitConversion.TIME_SECONDS,UnitConversion.TIME_MILLISECONDS),1);
					timer.start();
				}
				var pending:PendingResult = pendingResults[r] = new PendingResult(cause, advice, timer, netConn, this);
				
				var r: Responder = new Responder(pending.onResult, pending.onFail);
				
				var parameters:Array = [cause.method, r];
				if(cause.parameters && cause.parameters.length)parameters = parameters.concat(cause.parameters);
				if (cause.useCredentials){
					netConn.setCredentials(cause.userId || userId, cause.password || password);				
				}else{
					netConn.clearCredentials();
				}
				
				netConn.call.apply(null,parameters);
				
			}else{
				throw new Error("RemotingAdvice.execute() cannot be called until a netConnection has been specified");
			}
		}
	}
}
import org.farmcode.sodalityLibrary.external.remoting.adviceTypes.IRemotingAdvice;
import org.farmcode.sodality.advice.AsyncMethodAdvice;
import flash.utils.Timer;
import org.farmcode.sodality.advisors.IAdvisor;
import flash.net.NetConnection;
import flash.events.TimerEvent;
import flash.events.NetStatusEvent;
import org.farmcode.sodalityLibrary.errors.ErrorDetails;
import org.farmcode.sodalityLibrary.external.remoting.RemotingAdviceResultType;
import org.farmcode.sodalityLibrary.external.remoting.errors.RemotingErrorAdvice;
import org.farmcode.sodalityLibrary.external.remoting.advice.RemotingAdvice;
import org.farmcode.sodalityLibrary.external.remoting.errors.RemotingAdviceErrors;
	
class PendingExecution{
	public var cause:IRemotingAdvice;
	public var advice:AsyncMethodAdvice;
	public function PendingExecution(cause:IRemotingAdvice, advice:AsyncMethodAdvice){
		this.cause = cause;
		this.advice = advice;
	}
}
class PendingResult{
	private static const NET_STATUS_ERROR: String = "error";
	
	public var cause:IRemotingAdvice;
	public var advice:AsyncMethodAdvice;
	public var timer:Timer;
	public var result:Object;
	public var advisor:IAdvisor;
	public var netConn:NetConnection;
	
	public function PendingResult(cause:IRemotingAdvice, advice:AsyncMethodAdvice, timer:Timer, netConn:NetConnection, advisor:IAdvisor){
		this.cause = cause;
		this.advice = advice;
		this.timer = timer;
		this.advisor = advisor;
		this.netConn = netConn;
		if(timer)timer.addEventListener(TimerEvent.TIMER, onTimeout);
		netConn.addEventListener(NetStatusEvent.NET_STATUS, this.handleStatusEvent);
	}
	/**
	 * Handles a successful result from the remoting call
	 * 
	 * @param	result		Details of the successful result
	 */
	public function onResult(result:Object):void{
		if (cause.resultType == RemotingAdviceResultType.PENDING){
			resultReceived(RemotingAdviceResultType.SUCCESS, result);
		}
	}
	
	/**
	 * Handles a failed result from the remoting call
	 * 
	 * @param	result		Details of the failed result
	 */
	public function onFail( fault:Object ):void{
		if (cause.resultType == RemotingAdviceResultType.PENDING){
			var errorAdvice:RemotingErrorAdvice = new RemotingErrorAdvice(RemotingAdviceErrors.FAILED,
				cause, new ErrorDetails("Call failed: "+cause.method));
			errorAdvice.method = cause.method;
			errorAdvice.parameters = cause.parameters;
			errorAdvice.executeAfter = cause;
			advisor.dispatchEvent(errorAdvice);
			resultReceived(RemotingAdviceResultType.FAIL, fault);
		}
	}
	
	/**
	 * Handles a timeout result from the remoting call
	 * 
	 * @param	result		Details of the timeout result
	 */
	protected function onTimeout(e:TimerEvent):void{
		if (cause.resultType == RemotingAdviceResultType.PENDING){
			var errorAdvice:RemotingErrorAdvice = new RemotingErrorAdvice(RemotingAdviceErrors.TIMEOUT,
				cause, new ErrorDetails("Call timed out: "+cause.method));
			errorAdvice.method = cause.method;
			errorAdvice.parameters = cause.parameters;
			errorAdvice.executeAfter = cause;
			advisor.dispatchEvent(errorAdvice);
			resultReceived(RemotingAdviceResultType.TIMEOUT);
		}
	}
	private function handleStatusEvent(event: NetStatusEvent): void{
		if (event.info.level == NET_STATUS_ERROR){
			this.onFail(null);
		}
	}
	
	protected function resultReceived(resultType: String, result: * = null): void{
		cause.resultType = resultType;
		cause.result = result;
		
		netConn.removeEventListener(NetStatusEvent.NET_STATUS, this.handleStatusEvent);
		if(timer)timer.removeEventListener(TimerEvent.TIMER, onTimeout);
		advice.adviceContinue();
	}
}