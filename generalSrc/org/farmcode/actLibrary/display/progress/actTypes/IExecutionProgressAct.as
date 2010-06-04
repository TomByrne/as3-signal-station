package org.farmcode.actLibrary.display.progress.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IExecutionProgressAct extends IUniversalAct
	{
		function get message():String;
	}
}