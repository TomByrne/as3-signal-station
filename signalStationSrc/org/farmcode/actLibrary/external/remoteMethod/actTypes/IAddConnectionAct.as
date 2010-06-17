package org.farmcode.actLibrary.external.remoteMethod.actTypes
{
	import org.farmcode.actLibrary.external.remoteMethod.connections.IConnection;
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface IAddConnectionAct extends IUniversalAct
	{
		function get connectionId():String;
		function get connection():IConnection;
	}
}