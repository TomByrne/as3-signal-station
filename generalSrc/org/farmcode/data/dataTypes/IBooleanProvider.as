package org.farmcode.data.dataTypes
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IBooleanProvider
	{
		function get booleanValue():Boolean;
		
		/**
		 * handler(from:INumericalData)
		 */
		function get booleanValueChanged():IAct;
	}
}