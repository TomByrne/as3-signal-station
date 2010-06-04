package org.farmcode.data.dataTypes
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface ITriggerableAction
	{
		function triggerAction():IAdvice;
	}
}