package org.farmcode.sodality.events
{
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodality.utils.AdviceExecutionNode;
	import org.farmcode.sodality.utils.AdvisorBundle;
	
	import flash.events.Event;
	use namespace SodalityNamespace;

	public class PresidentEvent extends Event
	{
		public static const ADVISOR_ADDED: String = "advisorAdded";
		public static const ADVISOR_REMOVED: String = "advisorRemoved";
		public static const EXECUTION_BEGIN: String = "executionBegin";
		public static const ADVICE_EXECUTE: String = "adviceExecute";
		public static const EXECUTION_END: String = "executionEnd";
		
		public var advice:IAdvice;
		public var advisor:IAdvisor;
		SodalityNamespace var advisorBundle:AdvisorBundle;
		SodalityNamespace var adviceExecutionNode:AdviceExecutionNode;
		
		public function PresidentEvent(type:String, advice:IAdvice=null, advisor:IAdvisor=null, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
			this.advice = advice;
			this.advisor = advisor;
		}
		
		SodalityNamespace function continueExecution():void{
			if(type==ADVICE_EXECUTE)adviceExecutionNode.continueExecution();
			else if(type==EXECUTION_BEGIN)adviceExecutionNode.execute(null);
		}
		
		override public function clone():Event{
			var pEvent: PresidentEvent = new PresidentEvent(this.type, advice, advisor, this.bubbles, this.cancelable);
			pEvent.advisorBundle = advisorBundle;
			pEvent.adviceExecutionNode = adviceExecutionNode;
			return pEvent;
		}
	}
}