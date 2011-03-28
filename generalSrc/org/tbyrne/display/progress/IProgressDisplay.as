package org.tbyrne.display.progress
{
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	
	public interface IProgressDisplay
	{
		function set active(value:IBooleanProvider):void;
		function set measurable(value:IBooleanProvider):void;
		function set message(value:IStringProvider):void;
		function set units(value:IStringProvider):void;
		function set progress(value:INumberProvider):void;
		function set total(value:INumberProvider):void;
	}
}