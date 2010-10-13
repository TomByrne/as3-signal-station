package org.tbyrne.debug.nodeTypes
{
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;

	public interface IGraphStatisticNode extends IDebugNode
	{
		function get name():String;
		function get colour():Number;
		
		function get statisticProvider():INumberProvider;
		function get maximumProvider():INumberProvider;
		
		function get labelProvider():IStringProvider;
		function get summaryProvider():IStringProvider;
	}
}