package org.tbyrne.actLibrary.application.states.reactors
{
	import org.tbyrne.actLibrary.application.states.AppStateMatch;
	import org.tbyrne.acting.actTypes.IAct;

	public interface IAppStateReactor
	{
		function enable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct;
		function disable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct;
		function refresh(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct;
	}
}