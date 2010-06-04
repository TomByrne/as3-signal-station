package org.farmcode.sodalityLibrary.display.progress.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.actLibrary.display.progress.actTypes.IExecutionProgressAct;
	
	public interface IProgressAdvice extends IExecutionProgressAct
	{
		function get progress():Number;
		function get total():Number;
		function get units():String;
		function get measurable():Boolean;
	}
}