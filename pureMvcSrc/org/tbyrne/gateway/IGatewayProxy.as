package org.tbyrne.gateway
{
	import org.tbyrne.gateways.methodCalls.MethodCall;
	
	import org.puremvc.as3.interfaces.IProxy;
	
	public interface IGatewayProxy extends IProxy
	{
		function callMethod(method:MethodCall):void;
	}
}