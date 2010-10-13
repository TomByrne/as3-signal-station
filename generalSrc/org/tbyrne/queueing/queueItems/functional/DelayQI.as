package org.tbyrne.queueing.queueItems.functional
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.queueing.IQueueItem;

	public class DelayQI implements IQueueItem
	{
		public function get totalSteps():uint{
			return 1;
		}
		public function get stepFinished():IAct{
			return _stepFinished;
		}
		
		public var seconds:Number;
		
		private var _timer:Timer;
		private var _stepFinished:Act = new Act();
		
		public function DelayQI(seconds:Number=0){
			this.seconds = seconds;
		}

		public function step(currentStep:uint):void{
			if(seconds){
				_timer = new Timer(seconds*1000,1);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
				_timer.start();
			}else{
				onComplete();
			}
		}
		private function onComplete(e:Event=null):void{
			if(_timer){
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
				_timer = null;
			}
			_stepFinished.perform(this);
		}
	}
}