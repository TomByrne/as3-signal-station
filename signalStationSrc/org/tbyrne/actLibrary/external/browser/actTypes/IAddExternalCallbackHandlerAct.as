package org.tbyrne.actLibrary.external.browser.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface IAddExternalCallbackHandlerAct extends IUniversalAct
	{
		function get onlyAddIfNotAlready():Boolean;
		function get callbackName():String;
		function get callbackHandler():Function;
		function set addedSuccessfully(value:Boolean):void;
	}
}