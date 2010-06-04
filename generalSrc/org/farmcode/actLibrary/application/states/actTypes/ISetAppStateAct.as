package org.farmcode.actLibrary.application.states.actTypes
{
	import org.farmcode.actLibrary.application.states.AppStateMatch;
	import org.farmcode.actLibrary.application.states.states.IAppState;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.sodality.advice.IAdvice;
	

	public interface ISetAppStateAct extends IUniversalAct
	{
		function get state():IAppState;
		function get stateId():String;
		function get appStateMatch():AppStateMatch;
	}
}