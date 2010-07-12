package org.farmcode.actLibrary.external.browser.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface INavigateToURLAct extends IUniversalAct
	{
		function get linkUrl():String;
		function get targetWindow():String;
	}
}