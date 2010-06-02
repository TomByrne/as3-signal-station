package org.farmcode.sodality.triggerResponseCache
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.triggers.IAdviceTrigger;
	
	public interface ITriggerResponseCache
	{
		function addTrigger(trigger:IAdviceTrigger):void;
		function removeTrigger(trigger:IAdviceTrigger):void;
		function getTriggers(advice:IAdvice):Array;
	}
}