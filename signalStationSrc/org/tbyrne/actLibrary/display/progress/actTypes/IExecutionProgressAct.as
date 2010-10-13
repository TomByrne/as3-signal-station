package org.tbyrne.actLibrary.display.progress.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface IExecutionProgressAct extends IUniversalAct
	{
		function get message():String;
	}
}