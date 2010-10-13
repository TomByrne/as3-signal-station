package org.tbyrne.formatters
{
	import org.tbyrne.data.dataTypes.IStringData;
	import org.tbyrne.data.dataTypes.IValueProvider;

	public interface IFormatter extends IStringData
	{
		function set valueProvider(value:IValueProvider):void;
	}
}