package org.tbyrne.actLibrary.application.states.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ISetSerialisedStateAct extends IUniversalAct
	{
		function get serialisedState():String;
	}
}