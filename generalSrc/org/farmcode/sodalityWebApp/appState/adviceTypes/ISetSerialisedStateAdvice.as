package org.farmcode.sodalityWebApp.appState.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface ISetSerialisedStateAdvice extends IAdvice
	{
		function get serialisedState():String;
	}
}