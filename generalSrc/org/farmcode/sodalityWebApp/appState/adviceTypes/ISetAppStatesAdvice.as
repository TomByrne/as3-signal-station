package org.farmcode.sodalityWebApp.appState.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface ISetAppStatesAdvice extends IAdvice
	{
		function get states():Array;
	}
}