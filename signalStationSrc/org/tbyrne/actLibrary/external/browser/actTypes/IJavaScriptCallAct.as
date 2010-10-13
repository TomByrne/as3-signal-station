package org.tbyrne.actLibrary.external.browser.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface IJavaScriptCallAct extends IUniversalAct
	{
		function get methodName():String;
		function get parameters():Array;
		function set javascriptResult(value:*):void;
	}
}