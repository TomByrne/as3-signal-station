package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IValueProvider
	{
		function get value():*;
		
		/**
		 * handler(from:IValueProvider)
		 */
		function get valueChanged():IAct;
	}
}