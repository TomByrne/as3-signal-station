package org.farmcode.actLibrary.external.swfAddress.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface ISetSWFAddressAct extends IUniversalAct
	{
		function get swfAddress():String;
		function get onlyIfNotSet():Boolean;
	}
}