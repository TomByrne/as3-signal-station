package org.tbyrne.queueing.queueItems.functional
{
	import org.tbyrne.hoborg.IPoolable;
	import org.tbyrne.hoborg.ObjectPool;
	import org.tbyrne.queueing.queueItems.PendingResultQueueItem;

	public class MethodCallQI extends PendingResultQueueItem implements IPoolable
	{
		/*CONFIG::debug{
			private static var gettingNew:Boolean;
		}*/
		private static const pool:ObjectPool = new ObjectPool(MethodCallQI);
		public static function getNew(func:Function=null, parameters:Array=null):MethodCallQI{
			/*CONFIG::debug{
				gettingNew = true;
			}*/
			var ret:MethodCallQI = pool.takeObject();
			/*CONFIG::debug{
				gettingNew = false;
			}*/
			ret.func = func;
			ret.parameters = parameters;
			return ret;
		}
		
		
		override public function get totalSteps():uint{
			return callTimes;
		}
		
		public var interceptErrors:Boolean = false;
		public var releaseAfterCompletion:Boolean = true;
		
		public var func:Function;
		public var parameters:Array;
		public var callTimes:uint = 1;
		private var _calledTimes:uint = 0;
		
		public function MethodCallQI(func:Function=null, parameters:Array=null){
			/*CONFIG::debug{
				if(!gettingNew)Log.error( "MethodCallQI: MethodCallQI should be created via MethodCallQI.getNew()");
			}*/
			this.func = func;
			this.parameters = parameters;
		}
		
		override public function step(currentStep:uint):void{
			_calledTimes++;
			if(interceptErrors){
				try{
					_result = func.apply(null,parameters);
					dispatchSuccess();
				}catch(e:Error){
					dispatchFail();
				}
			}else{
				_result = func.apply(null,parameters);
				dispatchSuccess();
			}
			if(releaseAfterCompletion && _calledTimes==callTimes){
				release();
			}
		}
		override public function reset():void{
			super.reset();
			func = null;
			parameters = null;
			callTimes = 1;
			interceptErrors = false;
			_calledTimes = 0;
			_result = null;
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}
}