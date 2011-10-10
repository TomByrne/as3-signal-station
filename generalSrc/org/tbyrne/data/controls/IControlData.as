package org.tbyrne.data.controls
{
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.ITriggerableAction;

	public interface IControlData
	{
		function get label():IStringProvider;
		function get active():IBooleanProvider;
		
		function get selected():IBooleanProvider;
		function get numberValue():INumberProvider;
		function get stringValue():IStringProvider;
		function get selectedAction():ITriggerableAction;
		
		function get childData():*; // heirarchical data structures like cascading menus
	}
}