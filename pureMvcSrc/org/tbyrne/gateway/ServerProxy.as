package org.tbyrne.gateway
{
	import org.tbyrne.core.AbstractProxy;
	import org.tbyrne.core.SignalStationProxyNames;
	import org.tbyrne.gateways.IDataGateway;
	import org.tbyrne.gateways.methodCalls.MethodCall;
	
	public class ServerProxy extends AbstractProxy implements IGatewayProxy
	{
		public function get gateways():Vector.<IDataGateway>{
			return model.gateways;
		}
		public function set gateways(value:Vector.<IDataGateway>):void{
			model.gateways = value;
		}
		
		
		private var model:GatewayModel;
		
		public function ServerProxy(){
			model = new GatewayModel();
			super(SignalStationProxyNames.SERVER, model);
		}
		
		public function callMethod(method:MethodCall):void{
			model.callRemoteMethod(method);
		}
	}
}