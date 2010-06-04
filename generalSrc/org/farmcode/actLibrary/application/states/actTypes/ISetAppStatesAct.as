package org.farmcode.actLibrary.application.states.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface ISetAppStatesAct extends IUniversalAct
	{
		function get states():Array;
	}
}