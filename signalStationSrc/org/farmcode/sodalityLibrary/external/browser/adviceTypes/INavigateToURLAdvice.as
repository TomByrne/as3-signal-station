package org.farmcode.sodalityLibrary.external.browser.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface INavigateToURLAdvice extends IAdvice
	{
		function get linkUrl():String;
		function get targetWindow():String;
	}
}