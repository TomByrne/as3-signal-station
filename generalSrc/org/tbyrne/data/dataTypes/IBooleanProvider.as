package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IBooleanProvider
	{
		function get booleanValue():Boolean;
		
		/**
		 * handler(from:IBooleanProvider)
		 */
		function get booleanValueChanged():IAct;
	}
}