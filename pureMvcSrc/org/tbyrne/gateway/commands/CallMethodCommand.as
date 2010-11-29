package org.tbyrne.gateway.commands
{
	import org.tbyrne.gateways.methodCalls.MethodCall;
	import com.extro.models.ProxyNames;
	import org.tbyrne.gateway.IGatewayProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class CallMethodCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void {
			var serverProxy:IGatewayProxy = facade.retrieveProxy(ProxyNames.SERVER) as IGatewayProxy;
			serverProxy.callMethod(note.getBody() as MethodCall);
		}
	}
}