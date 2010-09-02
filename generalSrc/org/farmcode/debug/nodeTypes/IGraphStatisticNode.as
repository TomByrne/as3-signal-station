package org.farmcode.debug.nodeTypes
{
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.data.dataTypes.IStringProvider;

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