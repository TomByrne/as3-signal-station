package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IDateProvider extends IValueProvider
	{
		/**
		 * handler(from:IDateProvider)
		 */
		function get dateValueChanged():IAct;
		function get dateValue():Date;
	}
}