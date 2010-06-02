package org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface IGetSWFAddressAdvice extends IAdvice
	{
		function set swfAddress(value:String):void;
	}
}