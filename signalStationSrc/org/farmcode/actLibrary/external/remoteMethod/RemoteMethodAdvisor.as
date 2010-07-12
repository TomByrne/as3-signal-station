package org.farmcode.actLibrary.external.remoteMethod
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.external.remoteMethod.actTypes.IAddConnectionAct;
	import org.farmcode.actLibrary.external.remoteMethod.actTypes.IRemoteCallAct;
	import org.farmcode.actLibrary.external.remoteMethod.actTypes.ISetCredentialsAct;
	import org.farmcode.actLibrary.external.remoteMethod.connections.IConnection;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.phases.LogicPhases;

	public class RemoteMethodAdvisor extends UniversalActorHelper
	{
		
		public function get defaultConnection():IConnection{
			return _defaultConnection;
		}
		public function set defaultConnection(value:IConnection):void{
			if(_defaultConnection!=value){
				setConnection(null,value);
			}
		}
		
		private var _defaultConnection:IConnection;
		private var _connections:Dictionary = new Dictionary();
		
		public function setConnection(id:String, value:IConnection):void{
			if(!id){
				_defaultConnection = value;
			}else if(value){
				_connections[id] = value;
			}else{
				delete _connections[id];
			}
		}
		public function clearConnection(id:String):void{
			setConnection(id,null);
		}
		
		public function findConnection(id:String):IConnection{
			var connection:IConnection;
			if(!id){
				connection = _defaultConnection;
				if(!connection)throw new Error("RemoteMethodAdvisor.onSetCredentials: Default connection has not been set");
			}else{
				connection = _connections[id];
				if(!connection)throw new Error("RemoteMethodAdvisor.onSetCredentials: Connection with id "+id+" does not exist");
			}
			return connection;
		}
		
		public var addConnectionPhases:Array = [RemoteMethodPhases.ADD_CONNECTION];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{addConnectionPhases}")]
		public function onAddConnection(cause:IAddConnectionAct):void{
			setConnection(cause.connectionId,cause.connection);
		}
		
		public var setCredentialsPhases:Array = [RemoteMethodPhases.SET_CREDENTIALS];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{setCredentialsPhases}")]
		public function onSetCredentials(cause:ISetCredentialsAct):void{
			var connection:IConnection = findConnection(cause.connectionId);
			connection.setCredentials(cause.userId,cause.password);
		}
		
		public var remoteCallPhases:Array = [RemoteMethodPhases.REMOTE_CALL,LogicPhases.PROCESS_COMMAND];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{remoteCallPhases}")]
		public function onRemoteCall(execution:UniversalActExecution, cause:IRemoteCallAct):void{
			var connection:IConnection = findConnection(cause.connectionId);
			connection.execute(execution,cause);
		}
	}
}