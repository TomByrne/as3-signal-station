package org.farmcode.sodalityLibrary.external.browser.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface IJavaScriptCallAdvice extends IAdvice
	{
		function get methodName():String;
		function get parameters():Array;
		function set javascriptResult(value:*):void;
	}
}