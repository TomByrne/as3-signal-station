package org.farmcode.actLibrary.application.states.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface ISetDefaultSerialisedStateAct extends IUniversalAct
	{
		function get defaultSerialisedState():String;
	}
}