package org.farmcode.sodalityLibrary.utils.config.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface ISetDefaultConfigParamAdvice extends IAdvice
	{
		function get paramName():String;
		function get value():String;
	}
}