package org.tbyrne.actLibrary.external.remoteMethod.connections
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStreamLevels;
	import flash.net.RemotingHeaderTypes;
	import flash.net.Responder;
	
	import org.tbyrne.actLibrary.external.remoteMethod.PendingRemoteCall;
	import org.tbyrne.actLibrary.external.remoteMethod.actTypes.IRemoteCallAct;
	import org.tbyrne.acting.universal.UniversalActExecution;
	
	public class RemotingConnection extends AbstractConnection
	{
		override public function get connectionReady():Boolean{
			return _netConnection.connected;
		}
		public function get gatewayUrl():String{
			return _gatewayUrl;
		}
		public function set gatewayUrl(value:String):void{
			if(_gatewayUrl!=value){
				_gatewayUrl = value;
				_awaitingConnection = true;
				_netConnection.connect(value);
			}
		}
		
		/**
		 * A number (in seconds) determining the time before a call is regarded as timed out.
		 */
		public var timeout:Number = 60;
		
		private var _awaitingConnection:Boolean;
		private var _gatewayUrl:String;
		private var _netConnection:NetConnection = new NetConnection();
		
		public function RemotingConnection(){
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		protected function onNetStatus(e:NetStatusEvent):void{
			if(_awaitingConnection){
				_awaitingConnection = false;
				var info:Object = e.info;
				var failed:Boolean;
				if(info.level==NetStreamLevels.ERROR){
					/* if an error was thrown but we neither have a URL or are connected
					we'll assume we can happily ignore the error in disconnecting */
					if(_gatewayUrl || _netConnection.connected){
						failed = true;
					}
				}else if(_gatewayUrl && !_netConnection.connected){
					failed = true;
				}
				if(failed){
					throw new Error("NetConnection.connect failed: "+info.code);
				}else{
					_connectionReadyChanged.perform(this);
				}
			}
		}
		
		override protected function applyCredentials():void{
			var data: Object = new Object();
			data.userid = _userId;
			data.password = _password;
			_netConnection.addHeader(RemotingHeaderTypes.CREDENTIALS_HEADER_PARAM, false, data);
		}
		override protected function clearCredentials():void{
			_netConnection.addHeader(RemotingHeaderTypes.CREDENTIALS_HEADER_PARAM);
		}
		override protected function doExecute(pendingRemoteCall:PendingRemoteCall, execution:UniversalActExecution, remotingAct:IRemoteCallAct):Number{
			var responder: Responder = new Responder(pendingRemoteCall.onSucceed, pendingRemoteCall.onFail);
			var parameters:Array = [remotingAct.method, responder];
			if(remotingAct.parameters && remotingAct.parameters.length)parameters = parameters.concat(remotingAct.parameters);
			_netConnection.call.apply(null,parameters);
			return timeout;
		}
	}
}