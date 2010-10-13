package org.tbyrne.actLibrary.application.states.states{
	import org.tbyrne.actLibrary.application.states.AppStateMatch;

	public interface IAppState
	{
		function match(path:String):AppStateMatch;
		function reconstitute(match:AppStateMatch):String;
		function get reactors():Array;
		function get id():String;
	}
}