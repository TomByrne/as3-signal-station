package org.tbyrne.queueing.queueItems.functional
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.queueing.IQueueItem;

	public class DispatchEventQI implements IQueueItem
	{
		public function get totalSteps():uint{
			return 1;
		}
		public function get stepFinished():IAct{
			return _stepFinished;
		}
		
		public var event:Event;
		public var eventDispatcher:IEventDispatcher;
		
		protected var _stepFinished:Act = new Act();
		
		public function DispatchEventQI(event:Event=null, eventDispatcher:IEventDispatcher=null){
			this.event = event;
			this.eventDispatcher = eventDispatcher;
		}
		
		public function step(currentStep:uint):void{
			eventDispatcher.dispatchEvent(event);
			_stepFinished.perform(this);
		}
	}
}