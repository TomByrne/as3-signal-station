package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface INumberProvider extends IValueProvider, IStringProvider
	{
		function get numericalValue():Number;
		
		/**
		 * handler(from:INumericalData)
		 */
		function get numericalValueChanged():IAct;
	}
}