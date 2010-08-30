package org.farmcode.actLibrary.core
{
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.metadata.MetadataActorRegistry;
	import org.farmcode.acting.universal.reactions.MethodReaction;
	import org.farmcode.acting.universal.rules.ActInstanceRule;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.core.IScopedObject;
	import org.farmcode.display.core.ScopedObject;
	
	use namespace ActingNamspace;

	/**
	 * This is a helper class to simplify setting the scopeDisplay property of
	 * many UniversalAct objects
	 */
	public class UniversalActorHelper extends ScopedObject
	{
		
		override public function set asset(value:IDisplayAsset):void{
			if(super.asset!=value){
				for each(var view:IScopedObject in _children){
					view.scope = value;
				}
				super.asset = value;
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
		public function addMethodReaction(method:Function, act:IUniversalAct, beforePhases:Array, afterPhases:Array, doAsynchronous:Boolean=true, passParameters:Boolean=false):MethodReaction{
			var methodReaction:MethodReaction = new MethodReaction(method,doAsynchronous);
			methodReaction.passParameters = passParameters;
			methodReaction.addUniversalRule(new ActInstanceRule(act,beforePhases,afterPhases));
			addChild(methodReaction);
			return methodReaction;
		}
		public function addChild(view:IScopedObject):void{
			if(_children.indexOf(view)==-1){
				_children.push(view);
				view.scope = _asset;
			}else{
				throw new Error("act already added");
			}
		}
		public function removeChild(view:IScopedObject):void{
			var index:int = _children.indexOf(view);
			if(index!=-1){
				view.scope = null;
				_children.splice(index,1);
			}else{
				throw new Error("act hasn't been added");
			}
		}
		public function assessMetadata():void{
			if(_registered){
				if(!_metadataTarget || !_asset){
					_registered = false;
					MetadataActorRegistry.removeActor(_metadataTarget);
				}
			}else if(_metadataTarget && _asset){
				_registered = true;
				MetadataActorRegistry.addActor(_metadataTarget,_asset);
			}
		}
	}
}