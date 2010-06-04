package org.farmcode.data.dataTypes
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IArrayProvider extends IValueProvider
	{
		/**
		 * handler(from:IArrayProvider)
		 */
		function get arrayValueChanged():IAct;
		function get arrayValue():Array;
	}
}