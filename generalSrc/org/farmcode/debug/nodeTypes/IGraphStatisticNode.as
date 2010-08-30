package org.farmcode.debug.nodeTypes
{
	import org.farmcode.data.dataTypes.INumberProvider;

	public interface IGraphStatisticNode extends IDebugNode
	{
		function get label():String;
		function get colour():Number;
		function get statisticProvider():INumberProvider;
		function get showInSummary():Boolean;
	}
}