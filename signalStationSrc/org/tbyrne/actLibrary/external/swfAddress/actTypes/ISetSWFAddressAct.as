package org.tbyrne.actLibrary.external.swfAddress.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ISetSWFAddressAct extends IUniversalAct
	{
		function get swfAddress():String;
		function get onlyIfNotSet():Boolean;
	}
}