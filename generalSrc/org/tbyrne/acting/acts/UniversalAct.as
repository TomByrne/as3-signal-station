package org.tbyrne.acting.acts
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.UniversalActManager;
	import org.tbyrne.debug.logging.Log;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.ScopedObject;
	
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
		
		protected var _isAdded:Boolean;
		protected var _scopeChanged:Act;
		private var _scopedObject:ScopedObject = new ScopedObject();
		
		public function UniversalAct(){
			_scopedObject.addedChanged.addHandler(onAddedChanged);
			_scopedObject.assetChanged.addHandler(onScopeChanged);
		}
		private function onAddedChanged(from:ScopedObject):void{
			addedToManager(_scopedObject.added);
		}
		private function onScopeChanged(from:ScopedObject, oldAsset:IDisplayAsset):void{
			if(_scopedObject.asset){
				if(_scopeChanged)_scopeChanged.perform(this, oldAsset);
			}else{
				addedToManager(false);
			}
		}
		private function addedToManager(value:Boolean):void{
			if(_isAdded!=value){
				_isAdded = value;
				if(_isAdded){
					UniversalActManager.addAct(this);
				}else{
					UniversalActManager.removeAct(this);
				}
			}
		}
		
		public function temporaryPerform(scope:IDisplayAsset, ... params):void{
			this.scope = scope;
			perform.apply(null,params);
			this.scope = null;
		}
		override public function perform(...params):void{
			CONFIG::debug{
				if(!_scopedObject.asset){
					Log.log(Log.SUSPICIOUS_IMPLEMENTATION,"UniversalAct being performed without scopeDisplay (it will not act universally)");
				}
			}
			super.perform.apply(null,params);
		}
	}
}