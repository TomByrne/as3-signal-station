package org.farmcode.sodalityLibrary.external.browser.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IAddExternalCallbackHandlerAdvice extends IAdvice
	{
		function get onlyAddIfNotAlready():Boolean;
		function get callbackName():String;
		function get callbackHandler():Function;
		function set addedSuccessfully(value:Boolean):void;
	}
}