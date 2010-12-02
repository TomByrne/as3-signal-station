package org.tbyrne.gateway.commands
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.tbyrne.core.SignalStationProxyNames;
	import org.tbyrne.gateway.IGatewayProxy;
	import org.tbyrne.gateways.methodCalls.MethodCall;
	
	public class CallMethodCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void {
			var serverProxy:IGatewayProxy = facade.retrieveProxy(SignalStationProxyNames.SERVER) as IGatewayProxy;
			serverProxy.callMethod(note.getBody() as MethodCall);
		}
	}
}