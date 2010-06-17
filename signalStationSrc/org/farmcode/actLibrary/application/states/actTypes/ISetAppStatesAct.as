package org.farmcode.actLibrary.application.states.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface ISetAppStatesAct extends IUniversalAct
	{
		function get states():Array;
	}
}