package org.tbyrne.actLibrary.application.states.actTypes
{
	import org.tbyrne.actLibrary.application.states.AppStateMatch;
	import org.tbyrne.actLibrary.application.states.states.IAppState;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	

	public interface ISetAppStateAct extends IUniversalAct
	{
		function get state():IAppState;
		function get stateId():String;
		function get appStateMatch():AppStateMatch;
	}
}