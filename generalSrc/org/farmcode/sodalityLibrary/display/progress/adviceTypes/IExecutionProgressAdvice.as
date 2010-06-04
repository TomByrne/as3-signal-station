package org.farmcode.sodalityLibrary.display.progress.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IExecutionProgressAdvice extends IAdvice
	{
		function get message():String;
	}
}