package org.farmcode.actLibrary.external.browser.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface IGetCurrentURLAct extends IUniversalAct
	{
		function set currentURL(value:String):void;
	}
}