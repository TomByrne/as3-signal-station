package org.tbyrne.actLibrary.external.remoteMethod.connections
{
	import org.tbyrne.actLibrary.external.remoteMethod.actTypes.IRemoteCallAct;
	import org.tbyrne.acting.universal.UniversalActExecution;

	public interface IConnection
	{
		function setCredentials(userId:String, password:String):void;
		function execute(execution:UniversalActExecution, remoteCallAct:IRemoteCallAct):void;
	}
}