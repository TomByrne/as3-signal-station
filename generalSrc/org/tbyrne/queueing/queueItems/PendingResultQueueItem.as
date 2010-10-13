package org.tbyrne.queueing.queueItems
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.queueing.IQueueItem;

	public class PendingResultQueueItem implements IQueueItem, IPendingResult
	{
		public function get totalSteps():uint{
			// override me
			return 0;
		}
		public function get stepFinished():IAct{
			return _stepFinished;
		}
		public function get success():IAct{
			return _success;
		}
		public function get fail():IAct{
			return _fail;
		}
		
		public function get result():*{
			return _result;
		}
		
		public function PendingResultQueueItem(){
			super();
		}
		
		
		public function step(currentStep:uint):void{
			// override me
		}
		
		protected var _result:*;
		protected var _stepFinished:Act = new Act();
		protected var _success:Act = new Act();
		protected var _fail:Act = new Act();
		
		protected function dispatchSuccess():void{
			_success.perform(this);
			_stepFinished.perform(this);
		}
		protected function dispatchFail():void{
			_fail.perform(this);
			_stepFinished.perform(this);
		}
		public function reset():void{
			_stepFinished.removeAllHandlers();
			_success.removeAllHandlers();
			_fail.removeAllHandlers();
		}
	}
}