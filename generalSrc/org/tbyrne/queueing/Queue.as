package org.tbyrne.queueing
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	
	public class Queue implements IQueue
	{
		
		/**
		 * @inheritDoc
		 */
		public function get queueBegin():IAct{
			if(!_queueBegin)_queueBegin = new Act();
			return _queueBegin;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get queueEnd():IAct{
			if(!_queueEnd)_queueEnd = new Act();
			return _queueEnd;
		}
		
		protected var _queueEnd:Act;
		protected var _queueBegin:Act;
		
		protected var _queue:Array = [];
		protected var _runningItem:IQueueItem;
		protected var _stepsTaken:int = 0;
		protected var _pause:Boolean = false;
		
		/*public function pause():void{
			_pause = false;
		}
		
		public function resume():void{
			if(!_pause){
				_pause = true;
				doNext();
			}
		}*/
		
		public function addQueueItem(queueItem:IQueueItem, prioritise:Boolean=false):void{
			if(prioritise)_queue.unshift(queueItem);
			else _queue.push(queueItem);
			startQueue();
		}
		public function destroy():void{
			clearQueue();
			if(_runningItem){
				_runningItem.stepFinished.removeHandler(onComplete);
				_runningItem = null;
			}
		}
		public function clearQueue():void{
			_queue = [];
			_runningItem = null;
		}
		public function removeQueueItem(queueItem:IQueueItem):void{
			var index:int = _queue.indexOf(queueItem);
			if(index!=-1){
				_queue.splice(index,1);
			}
		}
		
		protected function startQueue():void{
			if(!_runningItem && _queue.length){
				if(_queueBegin)_queueBegin.perform(this);
				doNext();
			}
		}
		protected function doNext():void{
			if(!_pause){
				if(!_runningItem || _runningItem.totalSteps==_stepsTaken){
					if(_runningItem){
						_runningItem.stepFinished.removeHandler(onComplete);
						_runningItem = null;
					}
					if(_queue.length){
						_runningItem = _queue.shift();
						_runningItem.stepFinished.addHandler(onComplete);
						_stepsTaken = 0;
					}else{
						if(_queueEnd)_queueEnd.perform(this);
						return;
					}
				}
				_runningItem.step(_stepsTaken++);
			}
		}
		protected function onComplete(queueItem:IQueueItem):void{
			doNext();
		}
	}
}