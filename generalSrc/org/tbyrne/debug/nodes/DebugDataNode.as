package org.tbyrne.debug.nodes
{
	import org.tbyrne.debug.data.coreTypes.IDebugData;
	import org.tbyrne.debug.nodeTypes.IDebugDataNode;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.ProxyScopedObject;
	
	public class DebugDataNode extends ProxyScopedObject implements IDebugDataNode
	{
		
		public function get rendererData():IDebugData{
			return _rendererData;
		}
		public function set rendererData(value:IDebugData):void{
			//if(_rendererData!=value){
				_rendererData = value;
			//}
		}
		
		public function get pathId():String{
			return _pathId;
		}
		public function set pathId(value:String):void{
			//if(_pathId!=value){
				_pathId = value;
			//}
		}
		
		public function get parentPath():String{
			return _parentPath;
		}
		public function set parentPath(value:String):void{
			//if(_parentPath!=value){
				_parentPath = value;
			//}
		}
		
		private var _parentPath:String;
		private var _pathId:String;
		private var _rendererData:IDebugData;
		
		public function DebugDataNode(scopedObject:IScopedObject=null, pathId:String=null, debugData:IDebugData=null, parentPath:String=null){
			super(scopedObject);
			this.pathId = pathId;
			this.rendererData = debugData;
			this.parentPath = parentPath;
		}
	}
}