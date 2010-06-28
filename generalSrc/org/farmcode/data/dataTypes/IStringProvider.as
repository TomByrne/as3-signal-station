package org.farmcode.data.dataTypes
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IStringProvider extends IValueProvider
	{
		function get stringValue():String;
		
		/**
		 * handler(from:IStringProvider)
		 */
		function get stringValueChanged():IAct;
	}
}