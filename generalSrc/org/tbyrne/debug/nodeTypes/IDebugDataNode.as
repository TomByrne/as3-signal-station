package org.tbyrne.debug.nodeTypes
{
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.debug.data.coreTypes.IDebugData;

	public interface IDebugDataNode extends IDebugNode
	{
		function get rendererData():IDebugData;
		
		// these guys don't work yet
		function get pathId():String;
		function get parentPath():String;
	}
}