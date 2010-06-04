package org.farmcode.sodalityLibrary.utils.config.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface IGetConfigParamAdvice extends IAdvice
	{
		function get paramName():String;
		function get value():String;
		function set value(value:String):void;
	}
}