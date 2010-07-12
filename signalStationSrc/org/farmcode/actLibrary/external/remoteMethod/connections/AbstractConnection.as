package org.farmcode.actLibrary.external.remoteMethod.connections
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.farmcode.actLibrary.external.remoteMethod.PendingRemoteCall;
	import org.farmcode.actLibrary.external.remoteMethod.actTypes.IRemoteCallAct;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.utils.MethodCallQueue;
	
	public class AbstractConnection implements IConnection
	{
		public function get connectionReady():Boolean{
			// override me
			return false;
		}
		/**
		 * handler(from:AbstractConnection)
		 */
		public function get connectionReadyChanged():IAct{
			if(!_connectionReadyChanged)_connectionReadyChanged = new Act();
			return _connectionReadyChanged;
		}
		
		protected var _connectionReadyChanged:Act;
		
		protected var _userId:String;
		protected var _password:String;
		protected var _credsSet:Boolean;
		protected var _pendingCalls:MethodCallQueue;
		
		public function AbstractConnection(){
		}
		
		public function setCredentials(userId:String, password:String):void{
			if(_userId!=userId || _password!=password){
				_userId = userId;
				_password = password;
				if(_userId && _password){
					applyCredentials();
				}else{
					clearCredentials();
				}
			}
		}
		protected function applyCredentials():void{
			// override me
		}
		protected function clearCredentials():void{
			// override me
		}
		
		public function execute(execution:UniversalActExecution, remoteCallAct:IRemoteCallAct):void{
			if(connectionReady){
				var pendingRemoteCall:PendingRemoteCall = PendingRemoteCall.getNew(execution, remoteCallAct);
				var timeout:Number = doExecute(pendingRemoteCall, execution, remoteCallAct);
				if(!isNaN(timeout)){
					var onTimeout:Function = function(e:TimerEvent):void{
						pendingRemoteCall.onTimeout();
					}
					var timer:Timer = new Timer(timeout*1000,1);
					timer.addEventListener(TimerEvent.TIMER, onTimeout);
					timer.start();
				}
			}else{
				if(!_pendingCalls){
					_pendingCalls = new MethodCallQueue(execute);
					connectionReadyChanged.addHandler(onReadyChanged);
				}
				_pendingCalls.addMethodCall([execution,remoteCallAct]);
			}
		}
		/**
		 * @return time before timeout (in seconds)
		 */
		protected function doExecute(pendingRemoteCall:PendingRemoteCall, execution:UniversalActExecution, remotingAct:IRemoteCallAct):Number{
			// override me
			return NaN;
		}
		
		
		public function onReadyChanged(from:AbstractConnection):void{
			if(connectionReady){
				_pendingCalls.executePending();
			}
		}
	}
}