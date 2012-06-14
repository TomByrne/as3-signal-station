package org.tbyrne.debug.nodeTypes
{
	public interface IDebugDataNode extends IDebugNode
	{
		function get rendererData():*;
		function get pathId():String;
		function get parentPath():String;
	}
}