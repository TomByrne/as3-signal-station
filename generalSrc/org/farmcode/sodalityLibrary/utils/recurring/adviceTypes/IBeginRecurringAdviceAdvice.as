package org.farmcode.sodalityLibrary.utils.recurring.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.farmcode.sodalityLibrary.utils.recurring.RecurranceSettings;
	import org.farmcode.sodalityLibrary.utils.recurring.advice.IRecurranceAdvice;

	public interface IBeginRecurringAdviceAdvice extends IRecurranceAdvice, IRevertableAdvice
	{
		function get recurringAdvice():IAdvice;
		
		function get settingsGroup(): String;
		function get settings(): RecurranceSettings;
	}
}