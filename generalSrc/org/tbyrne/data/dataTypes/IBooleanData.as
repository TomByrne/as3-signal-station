package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IBooleanData
	{
		function set booleanValue(value:Boolean):void;
		function get booleanValue():Boolean;
		
		/**
		 * handler(from:IBooleanData)
		 */
		function get booleanValueChanged():IAct;
	}
}