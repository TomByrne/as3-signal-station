package org.farmcode.sodalityWebApp.appState.states
{
	import org.farmcode.sodalityWebApp.appState.AppStateMatch;

	public interface IAppState
	{
		function match(path:String):AppStateMatch;
		function reconstitute(match:AppStateMatch):String;
		function get reactors():Array;
		function get id():String;
	}
}