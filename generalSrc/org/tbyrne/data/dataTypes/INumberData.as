package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface INumberData extends IStringProvider
	{
		function set numericalValue(value:Number):void;
		function get numericalValue():Number;
		
		/**
		 * handler(from:INumericalData)
		 */
		function get numericalValueChanged():IAct;
	}
}