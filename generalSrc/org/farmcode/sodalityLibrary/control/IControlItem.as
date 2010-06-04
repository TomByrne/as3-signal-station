package org.farmcode.sodalityLibrary.control
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IControlItem
	{
		function get clickAdvice():IAdvice;
		function get rollOverAdvice():IAdvice;
		function get rollOutAdvice():IAdvice;
	}
}