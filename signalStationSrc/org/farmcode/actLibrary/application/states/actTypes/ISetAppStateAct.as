package org.farmcode.actLibrary.application.states.actTypes
{
	import org.farmcode.actLibrary.application.states.AppStateMatch;
	import org.farmcode.actLibrary.application.states.states.IAppState;
	import org.farmcode.acting.actTypes.IUniversalAct;
	

	public interface ISetAppStateAct extends IUniversalAct
	{
		function get state():IAppState;
		function get stateId():String;
		function get appStateMatch():AppStateMatch;
	}
}