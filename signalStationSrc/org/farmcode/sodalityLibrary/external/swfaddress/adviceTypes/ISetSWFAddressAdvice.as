package org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface ISetSWFAddressAdvice extends IAdvice
	{
		function get swfAddress():String;
		function get onlyIfNotSet():Boolean;
	}
}