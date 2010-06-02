package org.farmcode.sodalityLibrary.core.adviceTypes
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IRevertableAdvice extends IAdvice
	{
		function get doRevert():Boolean;
		function get revertAdvice():Advice;
	}
}