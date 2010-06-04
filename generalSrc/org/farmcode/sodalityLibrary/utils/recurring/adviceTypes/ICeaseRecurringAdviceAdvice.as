package org.farmcode.sodalityLibrary.utils.recurring.adviceTypes
{
	import org.farmcode.sodalityLibrary.utils.recurring.advice.IRecurranceAdvice;

	public interface ICeaseRecurringAdviceAdvice extends IRecurranceAdvice
	{
		function get revertFired(): Boolean;
	}
}