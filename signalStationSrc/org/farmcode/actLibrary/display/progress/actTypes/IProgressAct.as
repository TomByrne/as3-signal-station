package org.farmcode.actLibrary.display.progress.actTypes
{
	
	
	public interface IProgressAct extends IExecutionProgressAct
	{
		function get progress():Number;
		function get total():Number;
		function get units():String;
		function get measurable():Boolean;
	}
}