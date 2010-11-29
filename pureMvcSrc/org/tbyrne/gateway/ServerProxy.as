package org.tbyrne.gateway
{
	import org.tbyrne.gateways.methodCalls.MethodCall;
	import org.tbyrne.gateways.IDataGateway;
	import com.extro.models.AbstractProxy;
	import com.extro.models.ProxyNames;
	
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
			super(ProxyNames.SERVER, model);
		}
		
		public function callMethod(method:MethodCall):void{
			model.callRemoteMethod(method);
		}
	}
}