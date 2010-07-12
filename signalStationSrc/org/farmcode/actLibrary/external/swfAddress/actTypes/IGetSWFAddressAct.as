package org.farmcode.actLibrary.external.swfAddress.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface IGetSWFAddressAct extends IUniversalAct
	{
		function set swfAddress(value:String):void;
	}
}