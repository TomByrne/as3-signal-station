package org.tbyrne.actLibrary.application.states.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ISetAppStatesAct extends IUniversalAct
	{
		function get states():Array;
	}
}