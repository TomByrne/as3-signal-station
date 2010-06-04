package org.farmcode.actLibrary.display.progress.actTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IProgressAct extends IExecutionProgressAct
	{
		function get progress():Number;
		function get total():Number;
		function get units():String;
		function get measurable():Boolean;
	}
}