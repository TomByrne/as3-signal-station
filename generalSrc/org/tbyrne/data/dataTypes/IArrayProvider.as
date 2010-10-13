package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IArrayProvider extends IValueProvider
	{
		/**
		 * handler(from:IArrayProvider)
		 */
		function get arrayValueChanged():IAct;
		function get arrayValue():Array;
	}
}