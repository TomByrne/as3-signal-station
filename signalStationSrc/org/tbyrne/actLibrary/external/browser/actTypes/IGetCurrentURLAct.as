package org.tbyrne.actLibrary.external.browser.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface IGetCurrentURLAct extends IUniversalAct
	{
		function set currentURL(value:String):void;
	}
}