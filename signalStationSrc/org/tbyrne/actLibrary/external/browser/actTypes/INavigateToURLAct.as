package org.tbyrne.actLibrary.external.browser.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface INavigateToURLAct extends IUniversalAct
	{
		function get linkUrl():String;
		function get targetWindow():String;
	}
}