package org.tbyrne.actLibrary.application.states.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ISetDefaultSerialisedStateAct extends IUniversalAct
	{
		function get defaultSerialisedState():String;
	}
}