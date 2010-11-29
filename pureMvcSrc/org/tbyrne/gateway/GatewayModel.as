package org.tbyrne.gateway
{
	import org.tbyrne.gateways.methodCalls.MethodCall;
	import org.tbyrne.gateways.methodCalls.MethodResult;
	import org.tbyrne.gateways.IDataGateway;

	public class GatewayModel
	{
		public function get gateways():Vector.<IDataGateway>{
			return _gateways;
		}
		public function set gateways(value:Vector.<IDataGateway>):void{
			_gateways = value;
		}
		
		private var _gateways:Vector.<IDataGateway>;
		
		
		public function GatewayModel()
		{
		}
		public function callRemoteMethod(method:MethodCall):void{
			for each(var gateway:IDataGateway in _gateways){
				if(gateway.shouldExecuteCall(method)){
					gateway.executeCall(method);
				}
			}
		}
		/*public function callRemoteMethods(methods:Vector.<MethodCall>, finishHandler:Function):void{
			var methodList:Vector.<MethodCall> = methods.concat();
			var handler:Function = function(result:MethodResult):void{
				var index:int = methodList.indexOf(result.methodCall);
				methodList.splice(index,1);
				if(methodList.length==0)finishHandler();
			}
			for each(var method:MethodCall in methods){
				callRemoteMethod(method, handler);
			}
		}*/
	}
}