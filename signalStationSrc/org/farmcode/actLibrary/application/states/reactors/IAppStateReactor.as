package org.farmcode.actLibrary.application.states.reactors
{
	import org.farmcode.actLibrary.application.states.AppStateMatch;
	import org.farmcode.acting.actTypes.IAct;

	public interface IAppStateReactor
	{
		function enable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct;
		function disable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct;
		function refresh(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct;
	}
}