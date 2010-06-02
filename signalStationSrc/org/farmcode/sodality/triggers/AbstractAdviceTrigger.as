package org.farmcode.sodality.triggers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.farmcode.hoborg.ReadableObjectDescriber;
	import org.farmcode.sodality.TriggerTiming;
	import org.farmcode.sodality.advice.IAdvice;

	public class AbstractAdviceTrigger extends EventDispatcher implements IAdviceTrigger
	{
		[Property(toString="true",clonable="true")]
		public function set triggerTiming(value:String):void{
			if(!TriggerTiming.validate(value))throw new ArgumentError("AdviceTrigger must be set to one of the timing constants within TriggerTiming");
			else if(_triggerTiming!=value){
				_triggerTiming = value;
			}
		}
		public function get triggerTiming():String{
			return _triggerTiming;
		}
		
		private var _triggerTiming: String = TriggerTiming.BEFORE;
		
		public function AbstractAdviceTrigger(triggerTiming:String=null){
			super();
			if(triggerTiming)this.triggerTiming = triggerTiming;
		}
		
		public function check(advice:IAdvice):Boolean{
			return true;
		}
		protected function addToManyAdvice(adviceList:Array, cause:IAdvice, 
			dispatchTarget: IEventDispatcher = null):void{
			for each(var advice:IAdvice in adviceList){
				addToAdvice(advice,cause,null,dispatchTarget);
			}
		}
		protected function addToAdvice(advice:IAdvice, cause:IAdvice, triggerTiming:String=null,
			dispatchTarget: IEventDispatcher = null):void
		{
			if (!dispatchTarget)dispatchTarget = this;
			if(!triggerTiming)triggerTiming = this.triggerTiming;
			
			var both:Boolean = triggerTiming==TriggerTiming.BEFORE_AND_AFTER;
			if(both || triggerTiming==TriggerTiming.BEFORE){
				advice.executeBefore = cause;
				dispatchTarget.dispatchEvent(advice as Event);
				advice.executeBefore = null;
			}
			if(both || triggerTiming==TriggerTiming.AFTER){
				advice.executeAfter = cause;
				dispatchTarget.dispatchEvent(advice as Event);
				advice.executeAfter = null;
			}
		}
		override public function toString(): String{
			return ReadableObjectDescriber.describe(this);
		}
	}
}