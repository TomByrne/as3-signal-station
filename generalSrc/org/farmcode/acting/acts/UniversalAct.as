package org.farmcode.acting.acts
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.farmcode.ScopeDisplayObject;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.UniversalActManager;
	
	public class UniversalAct extends AsynchronousAct implements IUniversalAct
	{
		
		public function get active():Boolean{
			return _scopeDispalyObject.active;
		}
		public function set active(value:Boolean):void{
			_scopeDispalyObject.active = value;
		}
		public function get scopeDisplay():DisplayObject{
			return _scopeDispalyObject.scopeDisplay;
		}
		public function set scopeDisplay(value:DisplayObject):void{
			_scopeDispalyObject.scopeDisplay = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get scopeDisplayChanged():IAct{
			if(!_scopeDisplayChanged)_scopeDisplayChanged = new Act();
			return _scopeDisplayChanged;
		}
		
		protected var _scopeDisplayChanged:Act;
		private var _scopeDispalyObject:ScopeDisplayObject = new ScopeDisplayObject();
		
		public function UniversalAct(){
			_scopeDispalyObject.addedChanged.addHandler(onAddedChanged);
			_scopeDispalyObject.scopeDisplayChanged.addHandler(onScopeDisplayChanged);
		}
		private function onAddedChanged(from:ScopeDisplayObject):void{
			if(_scopeDispalyObject.added){
				UniversalActManager.addAct(this);
			}else{
				UniversalActManager.removeAct(this);
			}
		}
		private function onScopeDisplayChanged(from:ScopeDisplayObject):void{
			if(_scopeDisplayChanged)_scopeDisplayChanged.perform(this);
		}
		
		public function temporaryPerform(scopeDisplay:DisplayObject, ... params):void{
			this.scopeDisplay = scopeDisplay;
			perform.apply(null,params);
			this.scopeDisplay = null;
		}
		override public function perform(...params):void{
			if(!_scopeDispalyObject.scopeDisplay){
				trace("WARNING: UniversalAct being performed without scopeDisplay (it will not act universally)");
			}
			super.perform.apply(null,params);
		}
	}
}