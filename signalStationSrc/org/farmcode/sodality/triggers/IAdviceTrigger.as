package org.farmcode.sodality.triggers
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.events.IEventDispatcher;
	
	[Event(name="execute",type="org.farmcode.sodality.events.AdviceEvent")]
	public interface IAdviceTrigger extends IEventDispatcher
	{
		//function set advice(advice: IAdvice): void;
		//function get advice(): IAdvice;
		
		//function set adviceType(advice: String): void;
		//function get adviceType(): String;
		
		/**
		 * The check method should return false to continue being checked as it's
		 * sibling trigger's advice gets executed. Typically this is done when
		 * the causal advice doesn't yet contain enough data for the trigger to
		 * determine whether or not the resulting data should be added.
		 */
		function check(advice: IAdvice): Boolean;
	}
}