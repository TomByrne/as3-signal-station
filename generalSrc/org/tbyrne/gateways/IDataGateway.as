package org.tbyrne.gateways
{
	import org.tbyrne.gateways.methodCalls.MethodCall;

	/**
	 * IDataGateway is stateless, it should only execute server calls.
	 * It should serialise/deserialise requests though a data interpreter (if needed).
	 * 
	 * @author Tom Byrne
	 * 
	 */
	public interface IDataGateway
	{
		/**
		 * 
		 * @param methodCall
		 * @return true if this gateway shuold be used for this call.
		 * 
		 */
		function shouldExecuteCall(methodCall:MethodCall):Boolean;
		function executeCall(methodCall:MethodCall):void;
	}
}