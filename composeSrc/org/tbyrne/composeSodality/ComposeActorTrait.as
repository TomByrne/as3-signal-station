package org.tbyrne.composeSodality
{
	import org.tbyrne.actLibrary.core.ISimpleDataAct;
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	
	public class ComposeActorTrait extends AbstractTrait
	{
		
		public function get asset():IDisplayObject{
			return _actorHelper.asset;
		}
		public function set asset(value:IDisplayObject):void{
			_actorHelper.asset = value;
		}
		
		private var _actorHelper:UniversalActorHelper;
		private var _traits:Array;
		
		public function ComposeActorTrait(){
			super();
			
			_actorHelper = new UniversalActorHelper();
			_actorHelper.metadataTarget = this;
			_actorHelper.addedChanged.addHandler(onAdded);
			
			ComposeActTypes;
		}
		
		private function onAdded(... params):void
		{
			params = params;
		}
		
		override protected function onItemRemove():void{
			if(_traits && _traits.length){
				for each(var trait:ITrait in _traits){
					_item.removeTrait(trait);
				}
			}
		}
		override protected function onItemAdd():void{
			if(_traits && _traits.length){
				for each(var trait:ITrait in _traits){
					_item.addTrait(trait);
				}
			}
		}
		
		[ActRule(ActTypeRule,actType="<./ComposeActTypes.ADD_TRAITS>")]
		public function addTraits(cause:ISimpleDataAct):void{
			var traits:Array = cause.actData as Array;
			if(!_traits)_traits = [];
			if(_item){
				for each(var trait:ITrait in traits){
					_item.addTrait(trait);
					_traits.push(trait);
				}
			}else{
				_traits = _traits.concat(traits);
			}
		}
		[ActRule(ActTypeRule,actType="<./ComposeActTypes.REMOVE_TRAITS>")]
		public function removeTraits(cause:ISimpleDataAct):void{
			var traits:Array = cause.actData as Array;
			for each(var trait:ITrait in traits){
				if(_item)_item.removeTrait(trait);
				var index:int = _traits.indexOf(trait);
				_traits.splice(index,1);
			}
		}
	}
}