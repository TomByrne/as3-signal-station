package org.farmcode.sodalityLibrary.display.transition.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	
	public interface ITransitionAdvice extends IAdvice
	{
		function get doTransition():Boolean;
	}
}