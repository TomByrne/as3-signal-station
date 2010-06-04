package org.farmcode.data.dataTypes
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IValueProvider
	{
		function get value():*;
		
		/**
		 * handler(from:IValueProvider)
		 */
		function get valueChanged():IAct;
	}
}