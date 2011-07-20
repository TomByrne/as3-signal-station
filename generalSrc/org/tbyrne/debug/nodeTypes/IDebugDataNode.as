package org.tbyrne.debug.nodeTypes
{
	public interface IDebugDataNode extends IDebugNode
	{
		function get rendererData():*;
		
		// these guys don't work yet
		function get pathId():String;
		function get parentPath():String;
	}
}