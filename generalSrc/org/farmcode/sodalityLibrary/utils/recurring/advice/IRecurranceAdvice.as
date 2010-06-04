package org.farmcode.sodalityLibrary.utils.recurring.advice
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface IRecurranceAdvice extends IAdvice
	{
		function get recurranceId(): int;
		function set recurranceId(value:int):void;
	}
}