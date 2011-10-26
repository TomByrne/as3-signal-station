package org.tbyrne.composeLibrary.depth
{
	import org.tbyrne.compose.traits.ITrait;

	public class DepthTraitCollection
	{
		
		public function get length():int{
			return _allTraits.length;
		}
		
		public function get depthAdjudicator():IDepthAdjudicator{
			return _depthAdjudicator;
		}
		public function set depthAdjudicator(value:IDepthAdjudicator):void{
			if(_depthAdjudicator!=value){
				_depthAdjudicator = value;
				
				_allUnsorted = true;
				_unsortedTraits = null;
			}
		}
		
		private var _depthAdjudicator:IDepthAdjudicator;
		
		private var _allTraits:Vector.<ITrait> = new Vector.<ITrait>();
		private var _sortedTraits:Vector.<ITrait>;
		private var _unsortedTraits:Vector.<ITrait>;
		private var _allUnsorted:Boolean = true;
		
		public function DepthTraitCollection(depthAdjudicator:IDepthAdjudicator=null)
		{
			this.depthAdjudicator = depthAdjudicator;
		}
		
		public function addTrait(trait:ITrait):void{
			_allTraits.push(trait);
			
			if(!_allUnsorted){
				if(!_unsortedTraits)_unsortedTraits = new Vector.<ITrait>();
				_unsortedTraits.push(trait);
			}
		}
		public function removeTrait(trait:ITrait):void{
			removeFromArray(trait,_sortedTraits);
			removeFromArray(trait,_unsortedTraits);
		}
		
		private function removeFromArray(trait:ITrait, array:Vector.<ITrait>):void{
			if(!array)return;
			
			var index:int = array.indexOf(trait);
			if(index!=-1){
				array.splice(index,1);
			}
		}
		
		public function callOnTraits(func:Function, ascend:Boolean, additionalParams:Array=null):void{
			if(!_depthAdjudicator){
				Log.error("No depth adjudicator set");
			}
			var i:int;
			if(_allUnsorted){
				_allUnsorted = false;
				_sortedTraits = _allTraits.sort(_depthAdjudicator.compare);
			}else if(_unsortedTraits && _unsortedTraits.length){
				for each(var trait:ITrait in _unsortedTraits){
					for(i=0; i<_sortedTraits.length; ++i){
						var trait2:ITrait = _sortedTraits[i];
						if(_depthAdjudicator.compare(trait,trait2)>0){
							break;
						}
					}
					_sortedTraits.splice(i,0,trait);
				}
				_unsortedTraits = null;
			}
			
			var params:Array = [null,null];
			if(additionalParams){
				params = params.concat(additionalParams);
			}
			
			if(ascend){
				for(i=0; i<_sortedTraits.length; ++i){
					params[0] = i;
					params[0] = _sortedTraits[i];
					if(func.apply(null,params)){
						return;
					}
				}
			}else{
				for(i=_sortedTraits.length-1; i>=0; --i){
					params[0] = i;
					params[0] = _sortedTraits[i];
					if(func.apply(null,params)){
						return;
					}
				}
			}
		}
	}
}