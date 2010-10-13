package org.tbyrne.queueing
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.threading.AbstractThread;
	
	public class ThreadedQueue extends AbstractThread implements IQueue
	{
		public static function get intendedFPS():Number{
			return AbstractThread.intendedFPS;
		}
		public static function set intendedFPS(value:Number):void{
			AbstractThread.intendedFPS = value;
		}
		public static function getThread(id:String, newThreadSpeed:Number = 0.5):ThreadedQueue{
			for each(var thread:AbstractThread in AbstractThread.instances){
				var cast:ThreadedQueue = (thread as ThreadedQueue);
				if(cast && cast.id==id){
					return cast;
				}
			}
			return new ThreadedQueue(id, newThreadSpeed);
		}
		override public function get processing():Boolean{
			return (_queueItems.length>0);
		}
		public function get queueBegin():IAct{
			return threadBegin;
		}
		public function get queueEnd():IAct{
			return threadEnd;
		}
		
		
		/**
		 * handler(from:ThreadedQueue, queueItem:IQueueItem)
		 */
		public function get queueItemBegin():IAct{
			if(!_queueItemBegin)_queueItemBegin = new Act();
			return _queueItemBegin;
		}
		/**
		 * handler(from:ThreadedQueue, queueItem:IQueueItem)
		 */
		public function get queueItemEnd():IAct{
			if(!_queueItemEnd)_queueItemEnd = new Act();
			return _queueItemEnd;
		}
		
		protected var _queueItemBegin:Act;
		protected var _queueItemEnd:Act;
		
		public var id:String;
		
		protected var _queueItems:Array = [];
		protected var _currentItem:IQueueItem;
		
		protected var _frameStartTime:int;
		protected var _currentStepsDone:int;
		
		public function ThreadedQueue(id:String=null, intendedThreadSpeed:Number = 0.5){
			super(intendedThreadSpeed);
			this.id = id;
		}
		public function addQueueItem(queueItem:IQueueItem, prioritise:Boolean=false):void{
			var index:int = _queueItems.indexOf(queueItem);
			if(index==-1){
				var oldLength:Number = _queueItems.length;
				if(prioritise)_queueItems.unshift(queueItem);
				else _queueItems.push(queueItem);
				if(!oldLength)beginProcessing()
			}
		}
		public function removeQueueItem(queueItem:IQueueItem):void{
			var index:int = _queueItems.indexOf(queueItem);
			if(index!=-1){
				_queueItems.splice(index,1);
				if(!_queueItems.length)endProcessing()
			}
		}
		/*public function prioritiseJob(job:IThreadJob):void{
			var index:int = _queueItems.indexOf(job);
			if(index!=-1 && index!=0){
				_queueItems.splice(index,1);
				_queueItems.unshift(job);
			}
		}*/
		public function clearQueue():void{
			endProcessing();
			_queueItems = [];
		}
		override public function destroy():void{
			clearQueue();
			super.destroy()
		}
		override protected function beginProcessing():void{
			if(!_processing){
				setCurrent();
				
				_processing = true;
				if(_threadBegin)_threadBegin.perform(this);
				if(_queueItemBegin)_queueItemBegin.perform(this,_currentItem);
				FRAME_DISPATCHER.addEventListener(Event.ENTER_FRAME,onFrame);// always delay the beginning so that listeners can be added to events which finish immediately
			}
		}
		override protected function endProcessing():void{
			if(_processing){
				if(_currentItem)cleanUpCurrent();
				_currentStepsDone = 0;
				
				_processing = false;
				FRAME_DISPATCHER.removeEventListener(Event.ENTER_FRAME,onFrame);
				if(_threadEnd)_threadEnd.perform(this);
			}
		}
		protected function setCurrent():void{
			_currentItem = _queueItems[0];
			_currentItem.stepFinished.addHandler(process);
			_currentStepsDone = 0;
		}
		protected function cleanUpCurrent():void{
			if(_queueItemEnd)_queueItemEnd.perform(this,_currentItem);
			_currentItem.stepFinished.removeHandler(process);
			_currentItem = null;
		}
		protected function onFrame(e:Event):void{
			//trace("\nonFrame");
			FRAME_DISPATCHER.removeEventListener(Event.ENTER_FRAME,onFrame);
			_frameStartTime = getTimer();
			process();
		}
		override protected function process(... params):void{
			var remaining:int = _currentItem.totalSteps-_currentStepsDone;
			if(!remaining){
				cleanUpCurrent();
				_queueItems.shift();
				if(_queueItems.length){
					setCurrent();
					if(_queueItemBegin)_queueItemBegin.perform(this,_currentItem);
				}else{
					endProcessing();
					return;
				}
			}
			var frameTime:Number = getTimer()-_frameStartTime;
			//trace("process: "+frameTime,_processTime);
			if(frameTime>_processTime){
				//trace("timeout\n");
				FRAME_DISPATCHER.addEventListener(Event.ENTER_FRAME,onFrame);
				return;
			}
			_currentItem.step(_currentStepsDone++);
		}
	}
}