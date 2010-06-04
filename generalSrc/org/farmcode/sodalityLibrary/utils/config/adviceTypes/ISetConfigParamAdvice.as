package org.farmcode.sodalityLibrary.utils.config.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface ISetConfigParamAdvice extends IAdvice
	{
		function get paramName():String;
		function get value():*;
	}
}