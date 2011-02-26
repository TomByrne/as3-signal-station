package org.tbyrne.actLibrary.core
{
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.metadata.MetadataActorRegistry;
	import org.tbyrne.acting.universal.reactions.MethodReaction;
	import org.tbyrne.acting.universal.rules.ActInstanceRule;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.display.core.ScopedObject;
	
	use namespace ActingNamspace;

	/**
	 * This is a helper class to simplify setting the scopeDisplay property of
	 * many UniversalAct objects
	 */
	public class UniversalActorHelper extends ScopedObject
	{
		
		override public function set asset(value:IDisplayObject):void{
			if(super.asset!=value){
				if(_registered){
					MetadataActorRegistry.changeActorDisplay(_metadataTarget,value);
				}
				assessMetadata(value);
				for each(var view:IScopedObject in _children){
					view.scope = value;
				}
				super.asset = value;
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
				Log.error( "UniversalActorHelper.addChild: act already added");
			}
		}
		public function removeChild(view:IScopedObject):void{
			var index:int = _children.indexOf(view);
			if(index!=-1){
				view.scope = null;
				_children.splice(index,1);
			}else{
				Log.error( "UniversalActorHelper.removeChild: act hasn't been added");
			}
		}
		public function assessMetadata(asset:IDisplayObject=null):void{
			if(!asset)asset = _asset;
			if(_registered){
				if(!_metadataTarget || !asset){
					_registered = false;
					MetadataActorRegistry.removeActor(_metadataTarget);
				}
			}else if(_metadataTarget && asset){
				_registered = true;
				MetadataActorRegistry.addActor(_metadataTarget,asset);
			}
		}
	}
}