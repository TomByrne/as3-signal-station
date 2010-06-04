package org.farmcode.sodalityWebApp.appState.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface ISetDefaultSerialisedStateAdvice extends IAdvice
	{
		function get defaultSerialisedState():String;
	}
}