package org.farmcode.sodality.advice
{
	import org.farmcode.sodality.advisors.IAdvisor;
	
	import flash.events.IEventDispatcher;
	
	[Event(name="execute",type="org.farmcode.sodality.events.AdviceEvent")]
	[Event(name="abort",type="org.farmcode.sodality.events.AdviceEvent")]
	[Event(name="continue",type="org.farmcode.sodality.events.AdviceEvent")]
	[Event(name="complete",type="org.farmcode.sodality.events.AdviceEvent")]
	public interface IAdvice extends IEventDispatcher
	{
		function get advisor():IAdvisor;
		
		/*function set adviceType(adviceType: String): void;
		function get adviceType(): String;*/
		
		function set executeBefore(advice:IAdvice): void;
		function get executeBefore(): IAdvice;
		
		function set executeAfter(advice:IAdvice): void;
		function get executeAfter(): IAdvice;
		
		function get aborted(): Boolean;
		function set aborted(value: Boolean):void;
		
		function execute(cause:IAdvice,time:String):void;
		function cloneAdvice():IAdvice;
		function readyForExecution(cause:IAdvice):Boolean;
	}
}