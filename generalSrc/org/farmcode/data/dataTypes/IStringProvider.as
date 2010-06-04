package org.farmcode.data.dataTypes
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IStringProvider
	{
		function get stringValue():String;
		
		/**
		 * handler(from:IStringProvider)
		 */
		function get stringValueChanged():IAct;
	}
}