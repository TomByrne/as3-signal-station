package org.farmcode.formatters
{
	import org.farmcode.data.dataTypes.IStringConsumer;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.IValueProvider;

	public interface IFormatter extends IStringProvider, IStringConsumer
	{
		function set valueProvider(value:IValueProvider):void;
	}
}