package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IStringProvider extends IValueProvider
	{
		function get stringValue():String;
		
		/**
		 * handler(from:IStringProvider)
		 */
		function get stringValueChanged():IAct;
	}
}