package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IStringData
	{
		function set stringValue(value:String):void;
		function get stringValue():String;
		
		/**
		 * handler(from:IStringProvider)
		 */
		function get stringValueChanged():IAct;
	}
}