package org.tbyrne.actLibrary.external.swfAddress.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public interface IGetSWFAddressAct extends IUniversalAct
	{
		function set swfAddress(value:String):void;
	}
}