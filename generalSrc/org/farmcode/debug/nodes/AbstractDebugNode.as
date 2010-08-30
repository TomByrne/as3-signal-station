package org.farmcode.debug.nodes
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.debug.nodeTypes.IDebugNode;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.core.IScopedObject;

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