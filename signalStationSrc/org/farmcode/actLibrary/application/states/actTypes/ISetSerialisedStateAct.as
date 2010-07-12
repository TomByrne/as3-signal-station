package org.farmcode.actLibrary.application.states.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface ISetSerialisedStateAct extends IUniversalAct
	{
		function get serialisedState():String;
	}
}