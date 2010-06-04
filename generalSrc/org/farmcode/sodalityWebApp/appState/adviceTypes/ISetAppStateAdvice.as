package org.farmcode.sodalityWebApp.appState.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityWebApp.appState.AppStateMatch;
	import org.farmcode.sodalityWebApp.appState.states.IAppState;
	

	public interface ISetAppStateAdvice extends IAdvice
	{
		function get state():IAppState;
		function get stateId():String;
		function get appStateMatch():AppStateMatch;
	}
}