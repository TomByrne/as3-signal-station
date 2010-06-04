package org.farmcode.sodalityLibrary.display.progress.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IProgressAdvice extends IExecutionProgressAdvice
	{
		function get progress():Number;
		function get total():Number;
		function get units():String;
		function get measurable():Boolean;
	}
}