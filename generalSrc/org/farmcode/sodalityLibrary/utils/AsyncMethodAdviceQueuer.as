package org.farmcode.sodalityLibrary.utils
{
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advice.IAdvice;

	/**
	 * This class is used to collect AsyncMethodAdvice objects which are not
	 * yet ready to be processed (e.g. The advisor is still waiting on some
	 * information).<br>
	 * When the Advisor is ready, it can call the <code>executePending</code>
	 * method to call and clear all pending advice.
	 */
	public class AsyncMethodAdviceQueuer
	{
		public function get pendingCount():uint{
			return pending.length;
		}
		
		private var method:Function;
		private var pending:Array = [];
		
		public function AsyncMethodAdviceQueuer(method:Function=null){
			this.method = method;
		}
		
		public function addAdvice(cause:IAdvice, advice:AsyncMethodAdvice, timing:String, method:Function=null):void{
			pending.push(new PendingAdvice(method, cause, advice, timing));
		}
		public function executePending():void{
			for each(var pendingAdvice:PendingAdvice in pending){
				pendingAdvice.execute(method);
			}
			pending = [];
		}
	}
}
import org.farmcode.sodality.advice.AsyncMethodAdvice;
import org.farmcode.sodality.advice.IAdvice; 

class PendingAdvice{
	private var method:Function;
	private var cause:IAdvice;
	private var advice:AsyncMethodAdvice;
	private var timing:String;
	
	public function PendingAdvice(method:Function, cause:IAdvice, advice:AsyncMethodAdvice, timing:String){
		this.method = method;
		this.cause = cause;
		this.advice = advice;
		this.timing = timing;
	}
	public function execute(defaultMethod:Function):void{
		var meth:Function = (method!=null?method:defaultMethod);
		meth(cause, advice, timing);
	}
}