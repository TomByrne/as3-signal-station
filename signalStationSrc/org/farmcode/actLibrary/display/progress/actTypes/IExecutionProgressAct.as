package org.farmcode.actLibrary.display.progress.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface IExecutionProgressAct extends IUniversalAct
	{
		function get message():String;
	}
}