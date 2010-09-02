package org.farmcode.debug.nodes
{
	import org.farmcode.debug.nodeTypes.IDebugDataNode;
	import org.farmcode.display.core.IScopedObject;
	
	public class DebugDataNode extends AbstractDebugNode implements IDebugDataNode
	{
		
		public function get debugData():*{
			return _debugData;
		}
		public function set debugData(value:*):void{
			if(_debugData!=value){
				_debugData = value;
			}
		}
		
		private var _debugData:*;
		
		public function DebugDataNode(scopedObject:IScopedObject=null, debugData:*=null){
			super(scopedObject);
			this.debugData = debugData;
		}
	}
}