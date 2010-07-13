package org.farmcode.acting.acts
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.UniversalActManager;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.core.ScopedObject;
	
	public class UniversalAct extends AsynchronousAct implements IUniversalAct
	{
		
		public function get active():Boolean{
			return _scopedObject.active;
		}
		public function set active(value:Boolean):void{
			_scopedObject.active = value;
		}
		public function get scope():IDisplayAsset{
			return _scopedObject.scope;
		}
		public function set scope(value:IDisplayAsset):void{
			_scopedObject.asset = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scopeChanged():IAct{
			if(!_scopeChanged)_scopeChanged = new Act();
			return _scopeChanged;
		}
		
		protected var _scopeChanged:Act;
		private var _scopedObject:ScopedObject = new ScopedObject();
		
		public function UniversalAct(){
			_scopedObject.addedChanged.addHandler(onAddedChanged);
			_scopedObject.assetChanged.addHandler(onScopeChanged);
		}
		private function onAddedChanged(from:ScopedObject):void{
			if(_scopedObject.added){
				UniversalActManager.addAct(this);
			}else{
				UniversalActManager.removeAct(this);
			}
		}
		private function onScopeChanged(from:ScopedObject, oldAsset:IDisplayAsset):void{
			if(_scopeChanged)_scopeChanged.perform(this);
		}
		
		public function temporaryPerform(scope:IDisplayAsset, ... params):void{
			this.scope = scope;
			perform.apply(null,params);
			this.scope = null;
		}
		override public function perform(...params):void{
			if(!_scopedObject.asset){
				trace("WARNING: UniversalAct being performed without scopeDisplay (it will not act universally)");
			}
			super.perform.apply(null,params);
		}
	}
}