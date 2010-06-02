package org.farmcode.sodalityLibrary.errors.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IErrorAdvice extends IAdvice
	{
		function get errorType():String;
		function get errorTarget(): Object;
	}
}