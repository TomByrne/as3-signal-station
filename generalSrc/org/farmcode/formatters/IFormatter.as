package org.farmcode.formatters
{
	import org.farmcode.data.dataTypes.IStringData;
	import org.farmcode.data.dataTypes.IValueProvider;

	public interface IFormatter extends IStringData
	{
		function set valueProvider(value:IValueProvider):void;
	}
}