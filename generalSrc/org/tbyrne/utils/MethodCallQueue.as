package org.tbyrne.utils
{
	/**
	 * This class is used to collect method calls which are not
	 * yet ready to be processed.
	 */
	public class MethodCallQueue
	{
		public function get pendingCount():uint{
			return pending.length;
		}
		
		private var method:Function;
		private var pending:Array = [];
		
		public function MethodCallQueue(method:Function=null){
			this.method = method;
		}
		
		public function addMethodCall(params:Array, method:Function=null):void{
			pending.push(new PendingAdvice(method, params));
		}
		public function executePending():void{
			for each(var pendingAdvice:PendingAdvice in pending){
				pendingAdvice.execute(method);
			}
			pending = [];
		}
	}
}
import org.tbyrne.acting.actTypes.IAct;

class PendingAdvice{
	private var method:Function;
	private var params:Array;
	
	public function PendingAdvice(method:Function, params:Array){
		this.method = method;
		this.params = params;
	}
	public function execute(defaultMethod:Function):void{
		var meth:Function = (method!=null?method:defaultMethod);
		meth.apply(null,params);
	}
}