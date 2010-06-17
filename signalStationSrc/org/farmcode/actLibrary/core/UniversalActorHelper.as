package org.farmcode.actLibrary.core
{
	import flash.display.DisplayObject;
	
	import org.farmcode.ScopeDisplayObject;
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.IScopeDisplayObject;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.acting.metadata.MetadataActorRegistry;
	
	use namespace ActingNamspace;

	/**
	 * This is a helper class to simplify setting the scopeDisplay property of
	 * many UniversalAct objects
	 */
	public class UniversalActorHelper extends ScopeDisplayObject
	{
		
		override public function set scopeDisplay(value:DisplayObject):void{
			if(super.scopeDisplay!=value){
				for each(var scopeDisplayObject:IScopeDisplayObject in _children){
					scopeDisplayObject.scopeDisplay = value;
				}
				super.scopeDisplay = value;
				assessMetadata();
			}
		}
		
		public function get metadataTarget():Object{
			return _metadataTarget;
		}
		public function set metadataTarget(value:Object):void{
			if(_metadataTarget!=value){
				_metadataTarget = value;
				assessMetadata();
			}
		}
		
		private var _metadataTarget:Object;
		private var _children:Array = [];
		private var _registered:Boolean;
		
		public function UniversalActorHelper(){
		}
		public function addChild(scopeDisplayObject:IScopeDisplayObject):void{
			if(_children.indexOf(scopeDisplayObject)==-1){
				_children.push(scopeDisplayObject);
				scopeDisplayObject.scopeDisplay = _scopeDisplay;
			}else{
				throw new Error("act already added");
			}
		}
		public function removeChild(scopeDisplayObject:IScopeDisplayObject):void{
			var index:int = _children.indexOf(scopeDisplayObject);
			if(index!=-1){
				scopeDisplayObject.scopeDisplay = null;
				_children.splice(index,1);
			}else{
				throw new Error("act hasn't been added");
			}
		}
		public function assessMetadata():void{
			if(_registered){
				if(!_metadataTarget || !_scopeDisplay){
					_registered = false;
					MetadataActorRegistry.removeActor(_metadataTarget);
				}
			}else if(_metadataTarget && _scopeDisplay){
				_registered = true;
				MetadataActorRegistry.addActor(_metadataTarget,_scopeDisplay);
			}
		}
	}
}