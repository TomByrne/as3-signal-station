package org.tbyrne.debug.nodes
{
	import org.tbyrne.debug.nodeTypes.IDebugDataNode;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.ProxyScopedObject;
	
	public class DebugDataNode extends ProxyScopedObject implements IDebugDataNode
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