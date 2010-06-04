package org.farmcode.sodalityWebApp.appState.reactors
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityWebApp.appState.AppStateMatch;

	public interface IAppStateReactor
	{
		function enable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAdvice;
		function disable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAdvice;
		function refresh(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAdvice;
	}
}