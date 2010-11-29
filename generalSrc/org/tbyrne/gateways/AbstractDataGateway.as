package org.tbyrne.gateways
{
	import org.tbyrne.gateways.interpreters.IDataInterpreter;
	import org.tbyrne.gateways.methodCalls.MethodCall;
	import org.tbyrne.gateways.methodCalls.MethodResult;
	import org.tbyrne.utils.MethodCallQueue;

	public class AbstractDataGateway implements IDataGateway
	{
		private var _unsentCalls:MethodCallQueue;
		
		
		public function AbstractDataGateway()
		{
		}
		public function shouldExecuteCall(methodCall:MethodCall):Boolean{
			throw new Error("Override me");
			return false;
		}
		public function executeCall(methodCall:MethodCall):void{
			if(!isReady(methodCall)){
				if(!_unsentCalls)_unsentCalls = new MethodCallQueue(executeCall);
				_unsentCalls.addMethodCall([methodCall]);
			}else{
				var params:Array = methodCall.parameters;
				doCall(methodCall, params);
			}
		}
		protected function recheckReadiness():void{
			if(_unsentCalls){
				_unsentCalls.executePending();
			}
		}
		protected function isReady(methodCall:MethodCall):Boolean{
			return true;
		}
		protected function doCall(methodCall:MethodCall, params:Array):void{
			// override me
		}
		protected function finaliseCall(methodCall:MethodCall, result:*, handler:Function, interprettedParams:Array, interpreters:Vector.<IDataInterpreter>=null):void{
			if(interpreters){
				for each(var dataInterpreter:IDataInterpreter in interpreters){
					result = dataInterpreter.incoming(result);
				}
			}
			if(handler!=null){
				var methResult:MethodResult = new MethodResult();
				methResult.result = result;
				methResult.interprettedParams = interprettedParams;
				methResult.methodCall = methodCall;
				handler(methResult);
			}
		}
	}
}