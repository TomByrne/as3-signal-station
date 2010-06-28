package org.farmcode.data.dataTypes
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IDateProvider extends IValueProvider
	{
		/**
		 * handler(from:IDateProvider)
		 */
		function get dateValueChanged():IAct;
		function get dateValue():Date;
	}
}