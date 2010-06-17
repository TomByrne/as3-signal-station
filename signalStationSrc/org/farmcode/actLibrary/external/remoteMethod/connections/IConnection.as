package org.farmcode.actLibrary.external.remoteMethod.connections
{
	import org.farmcode.actLibrary.external.remoteMethod.actTypes.IRemoteCallAct;
	import org.farmcode.acting.universal.UniversalActExecution;

	public interface IConnection
	{
		function setCredentials(userId:String, password:String):void;
		function execute(execution:UniversalActExecution, remoteCallAct:IRemoteCallAct):void;
	}
}