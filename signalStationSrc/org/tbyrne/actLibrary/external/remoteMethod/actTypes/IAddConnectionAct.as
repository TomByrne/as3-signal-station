package org.tbyrne.actLibrary.external.remoteMethod.actTypes
{
	import org.tbyrne.actLibrary.external.remoteMethod.connections.IConnection;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface IAddConnectionAct extends IUniversalAct
	{
		function get connectionId():String;
		function get connection():IConnection;
	}
}