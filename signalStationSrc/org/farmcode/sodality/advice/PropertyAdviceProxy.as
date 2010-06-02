package org.farmcode.sodality.advice
{
	import org.farmcode.sodality.TriggerTiming;
	
	import flash.events.Event;
	
	public class PropertyAdviceProxy extends AbstractMemberAdvice
	{
		
		public function PropertyAdviceProxy(subject:Object=null, memberName:String=null, bortable:Boolean=true){
			super(subject, memberName, null, abortable);
			
			this.aborted = false;
		}
		
		public var lastAdvice:IAdvice;
		
		override protected function _execute(cause:IAdvice, time:String): void
		{
			var advice:IAdvice = subject[memberName];
			if(advice){
				if(time==TriggerTiming.AFTER)advice.executeAfter = cause;
				else if(time==TriggerTiming.BEFORE)advice.executeBefore = cause;
				dispatchEvent(advice as Event);
			}
			adviceContinue();
		}
	}
}