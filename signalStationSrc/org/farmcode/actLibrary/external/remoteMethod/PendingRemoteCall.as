package org.farmcode.actLibrary.external.remoteMethod
{
	import org.farmcode.actLibrary.external.remoteMethod.actTypes.IRemoteCallAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.hoborg.IPoolable;
	import org.farmcode.hoborg.ObjectPool;

	public class PendingRemoteCall implements IPoolable
	{
		private static const pool:ObjectPool = new ObjectPool(PendingRemoteCall);
		public static function getNew(execution:UniversalActExecution, remoteCallAct:IRemoteCallAct):PendingRemoteCall{
			var ret:PendingRemoteCall = pool.takeObject();
			ret.execution = execution;
			ret.remoteCallAct = remoteCallAct;
			return ret;
		}
		
		public var execution:UniversalActExecution;
		public var remoteCallAct:IRemoteCallAct;
		
		public function PendingRemoteCall(){
		}
		public function onSucceed(result:*):void{
			remoteCallAct.result = result;
			remoteCallAct.resultType = RemoteResultType.SUCCESS;
			execution.continueExecution();
			release();
		}
		public function onFail(info:*):void{
			remoteCallAct.result = info;
			remoteCallAct.resultType = RemoteResultType.FAIL;
			execution.continueExecution();
			release();
		}
		public function onTimeout():void{
			remoteCallAct.result = null;
			remoteCallAct.resultType = RemoteResultType.TIMEOUT;
			execution.continueExecution();
			release();
		}
		public function reset():void{
			execution = null;
			remoteCallAct = null;
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}
}