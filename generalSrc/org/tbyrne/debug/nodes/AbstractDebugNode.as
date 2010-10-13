package org.tbyrne.debug.nodes
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.debug.nodeTypes.IDebugNode;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.IScopedObject;

	public class AbstractDebugNode implements IDebugNode
	{
		
		public function get scopedObject():IScopedObject{
			return _scopedObject;
		}
		public function set scopedObject(value:IScopedObject):void{
			if(_scopedObject!=value){
				if(_scopedObject){
					_scopedObject.scopeChanged.removeHandler(onScopeChanged);
				}
				_scopedObject = value;
				if(_scopedObject){
					_scopedObject.scopeChanged.addHandler(onScopeChanged);
				}
			}
		}
		public function set scope(value:IDisplayAsset):void{
			_scopedObject.scope = value;
		}
		public function get scope():IDisplayAsset{
			return _scopedObject.scope;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scopeChanged():IAct{
			if(!_scopeChanged)_scopeChanged = new Act();
			return _scopeChanged;
		}
		
		protected var _scopeChanged:Act;
		private var _scopedObject:IScopedObject;
		
		public function AbstractDebugNode(scopedObject:IScopedObject=null){
			super();
			this.scopedObject = scopedObject;
		}
		protected function onScopeChanged(scopedObject:IScopedObject, oldScope:IDisplayAsset):void{
			if(_scopeChanged)_scopeChanged.perform(this,oldScope);
		}
	}
}